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

  def get_times(opening = 'open')
    grouped_times = []
    if ['lunch', 'open'].include?(opening)
      times = []
      time = '12:00'.to_time
      0.upto(9) do |i|
        times << time.strftime('%H:%M')
        time = time + 15.minutes
      end
      grouped_times << times
    end
    if ['dinner', 'open'].include?(opening)
      times = []
      time = '18:00'.to_time
      0.upto(14) do |i|
        times << time.strftime('%H:%M')
        time = time + 15.minutes
      end
      grouped_times << times
    end
    grouped_times
  end

end
