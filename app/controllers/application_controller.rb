class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.

  # NOTE!!!! For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :scope_current_tenant

  before_filter :authorize

  delegate :allow?, to: :current_permission
  helper_method :allow?

  delegate :allow_param?, to: :current_permission
  helper_method :allow_param?

  include CurrentCart

  def get_cart
    set_cart
  end
  helper_method :get_cart

  def get_takeaway
    set_takeaway
  end
  helper_method :get_takeaway

  def get_categories( root_category, product_flow = nil )
    category = Category.find_by_name( root_category )
    product_flow = category.product_flow unless product_flow
    results = Category.at_depth( 1 )
    if category
      #root_id = category.id
      results = results.where('root_id = ?', category.id)
    end
    case product_flow
    when 'incoming'
      results = results.where('product_flow <> ?', 'outgoing' )
    when 'outgoing'
      results = results.where('product_flow <> ?', 'incoming' )
    end
    results.order(:rank)
    #if category
    #  root_id = category.id
    #  results = Category.at_depth( 1 ).where('root_id = ? and product_flow <> ?', root_id, product_block ).order(:rank)
    #else
    #  results = Category.at_depth( 1 ).where('product_flow <> ?', product_block ).order(:rank)
    #end

  end
  helper_method :get_categories

  def set_categories( default_choices )
    choices = params[:choices].present? ? params[:choices] : default_choices
    get_categories(choices)
  end
  helper_method :set_categories

  def get_domains
    @domains ||= Element.where( :kind => 'domain').all
  end
  helper_method :get_domains

  def get_fields
    other_types = ["collection"]
    @fields = ItemField.where( 'field_type NOT IN (?)', other_types ).order(:rank, :name)
  end
  helper_method :get_fields

  def get_collections
    @collections = ItemField.where( :field_type => 'collection').order(:rank)
  end
  helper_method :get_collections

  def get_selections
    @selections = ItemField.where( :field_type => 'selection').order(:rank)
  end
  helper_method :get_selections

  def get_item_fields
    @item_fields ||= ItemField.where( ['field_type <> ?', 'collection']).all
  end
  helper_method :get_item_fields

  def get_accounts(type = nil)
    case type
      when 'expense'
        @accounts = Account.find_by_name('Expenses').children.load
      when 'fixed'
        @accounts = Account.find_by_name('Asset').children.where(name: 'Fixed Assets').load
      when 'sale'
        @accounts = Account.find_by_name('Revenue').children.load
      else
        @accounts = Account.at_depth( 1 ).load
    end
  end
  helper_method :get_accounts

  def get_suppliers( category_id = nil)
    unless category_id
      @suppliers = Supplier.all
    else
      category = Category.find(category_id).parent
      @suppliers = category.suppliers
    end
  end
  helper_method :get_suppliers

  def page_title
    current_tenant.name
  end
  helper_method :page_title

  def get_conversion_rate( to_currency, from_currency = 'GBP', amount = 1)
    country_code_src = from_currency
    country_code_dst = to_currency
    connection = Faraday.get("http://www.google.com/ig/calculator?hl=en&q=1#{country_code_src}=?#{country_code_dst}")

    currency_comparison_hash = eval connection.body #Google's output is not JSON, it's a hash

    dst_currency_value, *dst_currency_text = *currency_comparison_hash[:rhs].split(' ')
    dst_currency_value = dst_currency_value.to_f
    dst_currency_text = dst_currency_text.join(' ')

    (dst_currency_value * amount).round(2)
  end
  helper_method :get_conversion_rate

  def current_user
    @current_user ||= User.find_by_auth_token( cookies[:auth_token]) if cookies[:auth_token]
    @current_user ||= User.new
    # @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def admin_ok?
    ( CONFIG[:target_hosts].split(',').include? current_tenant.hostname ) || ( CONFIG[:allowed_hosts].split(',').include? request.remote_addr  )
  end
  helper_method :admin_ok?

  def current_tenant
    @current_tenant ||= Tenancy.find_by_hostname!(request.host)
  end
  helper_method :current_tenant

  def scope_current_tenant(&block)
    current_tenant.scope_schema("public", &block)
  end

  def current_permission
    @current_permission ||= Permissions.permission_for(current_user)
  end

  def current_resource
    nil
  end

  def authorize
    if current_permission.allow?(params[:controller], params[:action], current_resource)
      current_permission.permit_params! params
    else
      redirect_to root_url, alert: "Sorry - Not Authorized!"
    end
  end

  def title(code)
     code.gsub(/_/,' ').titleize
  end
  helper_method :title

  def set_booking_dates
    @booking_date = @booking.booking_date if @booking
    @booking_date ||= params['booking_date'].present? ? params['booking_date'].to_date : Date.today
    @bookings = Booking.where( booking_date: @booking_date ).order(:arrival, :customer_name)
    @requests = Booking.where( 'confirmed = ?', false ).order(:booking_date, :customer_name)
    @bookings_by_date = get_bookings(@booking_date)
    @bookings_next_month = get_bookings(@booking_date + 1.month)
    @events_by_date = get_events(@booking_date)
    @events_next_month = get_events(@booking_date + 1.month)
    @openings = get_openings( @booking_date.beginning_of_month, (@booking_date + 1.month).end_of_month )
  end
  helper_method :set_booking_dates

  def get_bookings(booking_date, period = 'future')
    start = (period == 'future' && booking_date <= Time.now.at_beginning_of_day) ? Time.now.to_date : booking_date.beginning_of_month
    stop = booking_date.end_of_month
    bookings = Booking.where('booking_date >= ? AND booking_date <= ?', start, stop)
    bookings = bookings.where('state <> ?', 'cancelled' ) if period == 'future'
    bookings.group_by(&:booking_date)
  end

  def get_orders(date = Time.now.to_date, state = '' )
    start = date.beginning_of_month
    stop = date.end_of_month
    orders = Order.where('effective_date >= ? AND effective_date <= ? AND supplier_id = ?', start, stop, current_tenant.supplier_id)
    orders = orders.where(state: state) unless state.blank?
    orders.order(:effective_date, :id)
    orders.group_by(&:effective_date)
  end

  def get_events(event_date)
    start = (event_date <= Time.now.at_beginning_of_day) ? Time.now.to_date : event_date.beginning_of_month
    stop = event_date.end_of_month
    #broadcasts = Broadcast.where('event_date >= ? AND event_date <= ?', start, stop )
    broadcasts = []
    Broadcast.where('event_date NOTNULL and event_date >= ? AND event_date <= ?', start, stop ).each do |event|
      date = event.event_date
      1.upto(event.repeat ) do |actual|
        if date >= start and date <= stop
          broadcasts << Broadcast.new(event.attributes.merge({event_date: date}))
        end
        date = event.event_date + eval("#{actual}.#{event.frequency}")
      end
    end
    broadcasts.group_by(&:event_date)
  end

  def open?(day_to_check = Time.now)
    openings = []
    Opening.where('start_date <= ?', day_to_check).each do |opening|
      if opening.finish_date >= day_to_check
        date = opening.start_date
        if opening.end_date.blank?
          1.upto(opening.repeat ) do |actual|
            if date == day_to_check
              openings << Opening.new(opening.attributes.merge({start_date: date}))
            end
            date = opening.start_date + eval("#{actual}.#{opening.frequency}")
          end
        else
          #i = 0
          while (date <= day_to_check and date <= opening.end_date) do
            #i += 1
            opening.start_date = date
            if date == start
              openings << Opening.new(opening.attributes.merge({start_date: date}))
            end
            date = date + eval("1.#{opening.frequency}")
          end
        end

      end
    end
    openings
  end
  helper_method :open?


  def get_openings(start, finish)
    openings = []
    Opening.where('start_date <= ?', finish).each do |opening|
      if opening.finish_date >= start
        date = opening.start_date
        if opening.end_date.blank?
          1.upto(opening.repeat ) do |actual|
            if date >= start and date <= finish
              openings << Opening.new(opening.attributes.merge({start_date: date}))
            end
            date = opening.start_date + eval("#{actual}.#{opening.frequency}")
          end
        else
          #i = 0
          while (date <= finish and date <= opening.end_date) do
            #i += 1
            opening.start_date = date
            if date >= start and date <= finish
              openings << Opening.new(opening.attributes.merge({start_date: date}))
            end
            date = date + eval("1.#{opening.frequency}")
          end
        end

      end
    end
    openings.group_by(&:start_date)
  end
  helper_method :get_openings

  def set_daily_dates
    @daily_date = params['daily_date'].present? ? params['daily_date'].to_date : Date.today.beginning_of_month
    start = (@daily_date >= Time.now.at_beginning_of_day) ? Time.now.to_date : @daily_date.beginning_of_month
    stop = @daily_date.end_of_month
    start = start - start.strftime('%w').to_d.days
    stop = stop + (6 - stop.strftime('%w').to_d).days
    #@daily_date = start
    @dailies_by_date = get_dailies(start, stop)
    @timesheets_by_date = get_timesheets(start, stop)
    @timesheets = Timesheet.includes(:employee).joins('LEFT OUTER JOIN dailies ON dailies.account_date = timesheets.work_date AND dailies.session = timesheets.session').where( "timesheets.work_date >= ? AND timesheets.work_date <= ? and employee_id = ?", start, stop, params[:employee] ).order('work_date, session DESC').select("timesheets.*, dailies.tips_cents as tips, dailies.headcount as headcount").group_by(&:work_date)
    @bookings = get_bookings(@daily_date, 'past')
    @orders = get_orders(@daily_date, 'complete')
  end
  helper_method :set_daily_dates

  def get_dailies(start, stop)
    @dailies = Daily.where('account_date >= ? AND account_date <= ?', start, stop ).order('account_date, session DESC')
    @dailies.group_by(&:account_date)
  end

  def get_timesheets(start, stop)
    Timesheet.joins(:employee).where('work_date >= ? AND work_date <= ?', start, stop ).order('work_date, session DESC, first_name').group_by(&:work_date)
  end

  def get_headcount
    Timesheet.where('work_date = ? AND session = ?', @daily.account_date, @daily.session).size
  end

  def get_work_month(month)
    start = month.beginning_of_month
    stop = month.end_of_month
    start = start - start.strftime('%w').to_d.days
    stop = stop + (6 - stop.strftime('%w').to_d).days
    "#{start}:#{stop}"
  end
  helper_method :get_work_month

  def get_rate_cents(employee, work_date)
    employee.pay_rates.where('effective_date <= ?', work_date).first.rate_cents
  end
  helper_method :get_rate_cents

  def get_fy(date)
    year = date.year
    date >= "06-04-#{}".to_date ? year : year - 1
  end
  helper_method :get_fy

  def get_balance(date)
    limits = get_work_month(date).split(':')
    start = limits[0]
    stop = limits[1]
    stop = Date.today.strftime('%Y-%m-%d') if stop.to_date > Date.today
    Order.where("effective_date >= ? AND effective_date <= ? AND state = ?", start, stop, 'test' ).order(:effective_date)
  end
  helper_method :get_balance

end
