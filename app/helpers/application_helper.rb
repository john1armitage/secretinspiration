module ApplicationHelper
  include PgArrayParser

  def lookup_roles
    Element.where( :kind => 'role').order(:rank)
  end

  def get_categories_for_item_type
    @categories = Category.after_depth(1).select(:id, :name, :parent_name).load
  end

  def make_title(input)
    input.gsub(/_/," ").gsub(/[^0-9a-z ]/i, '').titleize
  end

  def parse_pg( pg_array )
    pg_array.parse_pg_array
  end

  def markdown(text)
    #options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis]
    #Redcarpet.new(text, *options).to_html.html_safe
    #Redcarpet::Markdown.new(renderer, extensions = {})
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true).render(text).html_safe
  end

  def embolden(text)
    text.gsub(/<scb>/,"<span class='bold'>").gsub(/<\/s>/,"</span>")
  end

  def pluralize_only(count, noun, text = nil)
    if count != 0
      count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
    end
  end
  def get_months(date, number)
    months = []
    0.upto(number) do |m|
      months << [date.next_month(m).strftime("%B %Y"), date.next_month(m)]
    end
    months
  end
  def get_weeks(month)
    weeks = []
    limits = get_work_month(month).split(':')
    week_start = limits[0].to_date
    stop = limits[1].to_date
    while week_start <= stop and week_start < Date.today do
      weeks << week_start.strftime('%d-%m-%Y')
      week_start += 7.days
    end
    weeks.reverse
  end

  def get_times(opening = 'open', purpose = '')
    dinner_open = CONFIG[:dinner_open]
    grouped_times = []
    now = Time.now.to_time
    if ['lunch', 'open'].include?(opening)
      times = []
      time = CONFIG[:lunch_open].to_time
      0.upto(9) do |i|
        times << time.strftime('%H:%M') unless purpose == 'takeaway' && now > time
        time = time + 15.minutes
      end
      grouped_times << times
    end
    if ['dinner', 'open'].include?(opening)
      times = []
      time = dinner_open.to_time
      0.upto(14) do |i|
        times << time.strftime('%H:%M')  unless purpose == 'takeaway' && now > time
        time = time + 15.minutes
      end
      grouped_times << times
    end
    if ['timesheet'].include?(purpose)
      times = []
      time = dinner_open.to_time - 1.hour
      0.upto(30) do |i|
        times << time.strftime('%H:%M')  unless purpose == 'takeaway' && now > time
        time = time + 15.minutes
      end
      grouped_times << times
    end
    grouped_times
  end

  def apply_offer(offer, meal)
    line_items = meal.line_items.joins(variant: {item: {category: :category}})
    applies = []
    line_items.each do |line_item|
      if (offer.categories.include? line_item.variant.item.category.id.to_s) || (offer.categories.include? line_item.variant.item.category.category.id.to_s)
        applies << line_item
      end
    end
    discount = 0.00
    case offer.offer_type
      when '2-for-1'
        prices = []
        applies.each do |li|
          li.quantity.times do
            prices << (li.net_item + li.tax_item)
            # discount = every other
          end
          discount = prices.sort.reverse.select.each_with_index { |str, i| i.odd? }.reduce(:+)
        end
      when 'fixed_price'
        applies.each do |li|
          li.quantity.times do
            total = li.net_item.to_d + li.tax_item.to_d
            discount += (total - offer.amount)  if total > offer.amount
          end
        end
      when 'percent_off'
        applies.each do |li|
          li.quantity.times do
            discount += ((li.net_item.to_d + li.tax_item.to_d) * offer.amount / 100)
            # discount = every other
          end
        end
    end
    discount
  end
  def pounds(price)
    number_to_currency(price, :unit => "£")
  end
  def pax(pax)
    "#{pax} pax"
  end
  def week_number(date)
    date.to_date.beginning_of_week.strftime('%U')
  end
  def week_start(date)
    date.beginning_of_week.strftime('%d-%m-%y')
  end
  def HMRC_week_number(date)
    fy_start = "06-04-#{Date.today.year}".to_date
    fy_start = fy_start - 1.year if fy_start > date
    (((date - fy_start)/7).to_i + 1)
  end
  def broadcast(channel, &block)
    message = {:channel => channel, :data => capture(&block), :ext => {:auth_token =>  :FAYE_TOKEN}}
#    uri = URI.parse("http://#{current_tenant.hostname}:9292/faye")
    uri = URI.parse("https://#{current_tenant.hostname}/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end
