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
    title = current_tenant.name
    title += ": #{params[:id].gsub(/_/,' ').titleize}" if params[:id].present?
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
    #true
  end
  helper_method :admin_ok?

  def current_tenant
    @current_tenant ||= Tenancy.find_by_hostname!(request.host.gsub(/www./,''))
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
     code.gsub(/[\"\[\]]/,"").gsub(/_/,' ').titleize
  end
  helper_method :title

  def terse(code)
     code.gsub(/Verna\'s/,"")
  end
  helper_method :terse

  def ungrouping(code)
    code.gsub(/[^a-z ]/i,"")
  end
  helper_method :ungrouping

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
    @book_orders = get_orders(@daily_date, 'complete')
  end
  helper_method :set_daily_dates


  def set_analysis_dates
     @type = params['type'].present? ? params['type'] : 'food'
     @cat = params['cat'].present? ? params['cat'] : ''
     @sub = params['sub'].present? ? params['sub'] : ''
     if params['start'].present? and not params['start'].blank?
       @start = params['start'].to_date
       @stop = (params['stop'].present? and not params['stop'].blank?) ? params['stop'].to_date : Date.today
     elsif params['week'].present? and not params['week'].blank?
       @start = params['week'].to_date
       @stop = @start + 6
     elsif params['month'].present? and not params['month'].blank?
       @start = params['month'].to_date
       @stop = @start.end_of_month
     else
       @start = Date.today.beginning_of_month
       @stop = @start.end_of_month
     end
     @start = Date.today if @start > Date.today
     @stop = Date.today if @stop > Date.today
     @stop = @start if @stop < @start
  end
  helper_method :set_analysis_dates

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
    employee.pay_rates.where('effective_date <= ?', work_date).order('effective_date DESC').first.rate_cents
  end
  helper_method :get_rate_cents

  def get_fy(date)
    year = date.year
    date >= "06-04-#{year}".to_date ? year : year - 1
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

  def get_active(meal, course_name)
    #if [course_name, 'ordered', 'confirmed'].include?(meal.state)
    if [course_name, 'ordered'].include?(meal.state)
      active = 'active'
    elsif [course_name, 'ready'].include?(meal.state)
        active = 'ready'
    else
      course_name = 'main' if course_name == 'side'
      sub_state = meal.state.gsub(/_/,'').gsub(/starter/,'').gsub(/main/,'').gsub(/dessert/,'')
      current_course = meal.state.gsub(/_/,'').gsub(/ready/,'').gsub(/served/,'')
      active = (current_course == course_name) ? sub_state : 'info'
    end
    active
  end
  helper_method :get_active

  def get_meals
    @active_tables = Meal.where("state NOT IN ('billed', 'complete')").includes(seating: [:booking] ).where("seating_id::INT > 0").order('created_at DESC')
    @arrivals = @active_tables.where("pholourie = 'false'").order('created_at')
    # @meals = Meal.includes(:line_items, seating: [:booking] ).where("state NOT IN ('billed', 'active', 'complete','main_served') AND state NOT LIKE 'dessert%' AND seating_id::INT > 0").order('ordered_at')
    @meals = Meal.includes(:line_items, seating: [:booking] ).where("state NOT IN ('billed', 'active', 'complete') AND state NOT LIKE 'dessert%' AND seating_id::INT > 0").order('ordered_at')
    if current_user.role.name == 'operator'
      @meals = @meals.where("state <> 'main_served'")
    end
    @afters = Meal.includes(:line_items, seating: [:booking] ).where("state NOT IN ('dessert_served') AND state LIKE 'dessert%' AND seating_id::INT > 0").order('ordered_at')
    @takeaways = Meal.includes(:line_items).where("state IN ('ordered','ready') AND seating_id IS NULL").order(:start_time, :created_at)
  end
  def collection_to_options(categories, option = 'id')
    cats = []
    categories.each do |c|
      if option == 'id'
        cats << [c.name.gsub(/_/, ' ').titleize, c.id]
      else
        cats << [c.name.gsub(/_/, ' ').titleize, c.name]
      end
    end
    cats
  end

  def week_number(date)
    date.to_date.beginning_of_week.strftime('%U')
  end
  helper_method :week_number

  def week_start(date)
    date.beginning_of_week.strftime('%d-%m-%y')
  end
  helper_method :week_start

  def HMRC_week_number(date)
    fy_start = "06-04-#{date.year}".to_date
    fy_start = fy_start - 1.year if fy_start > date
    (((date - fy_start)/7).to_i + 1)
  end
  helper_method :HMRC_week_number

  # def HMRC_week_number(date)
  #   fy_start = "06-04-#{Date.today.year}".to_date
  #   fy_start = fy_start - 1.year if fy_start > date
  #   (((date - fy_start)/7).to_i + 1)
  # end
  # helper_method :HMRC_week_number

  def get_fy_start
    fy_start = "01-11-#{Date.today.year}".to_date
    fy_start = fy_start - 1.year if fy_start > Date.today
    fy_start
  end

  def fy_to_date
    period = []
    period << get_fy_start #.strftime("%Y-%m-%d")
    period << Date.today #.strftime("%Y-%m-%d")
  end
  def fq_to_date
    period = []
    month = Date.today.month
    month_in_quarter = (month + (month < 11 ? 12 : 0) - 11) % 3
    period << Date.today.beginning_of_month - month_in_quarter.month
    period << Date.today
  end
  def last_fy
    period = []
    period << get_fy_start - 1.year
    period << period[0] - 1.day + 1.year
  end
  def last_fq
    period = []
    month = Date.today.month
    month_in_quarter = (month + (month < 11 ? 12 : 0) - 11) % 3
    period << Date.today.beginning_of_month - month_in_quarter.month - 3.month
    period << period[0] +3.month - 1.day
  end

  def allocation_accounts
    groupings = []
    allocations = []
    accounts = ['COGS','Overheads','Fixed Assets']
    accounts.each do |a|
      if account = Account.find_by_name(a) #.select(:id, :name)
        groupings << account
      end
    end
    groupings.each do |g|
      allocations << g
      g.children.order(:code).each do |c|
        allocations << c
      end
    end
    allocations
  end
  helper_method :allocation_accounts

  def grouped_accounts
    grouped = []
    groupings = []
    allocations = []
    accounts = ['Direct Costs','Overheads','Disallowed','Fixed Assets','Current Assets','Current Liabilities','Long Term Liabilities']
    accounts.each do |a|
      if account = Account.find_by_name(a) #.select(:id, :name)
        groupings << account
      end
    end
    groupings.each do |g|
      grouping = g.name
      children = []
      g.children.order(:code).each do |c|
        children << [c.name, c.id]
      end
      allocations << [grouping, children]
    end
    allocations
  end
  helper_method :grouped_accounts

  def process_timesheets(timesheets)
    hours = 0.00
    wages = 0.00
    tips = 0.00
    week_hours = 0.00
    week_wages = 0.00
    week_tips = 0.00
    week_bonus = 0.00
    week_holiday = 0.00
    tips_share = 0.00
    total_tips_in = 0.00
    total_tips_out = 0.00
    wages = []
    if timesheets.size > 0
      work_date = params[:week].to_date
      pay_date = params[:week].to_date + 10.days
      week = week_number(pay_date) #.to_date.strftime('%U')
      hmrc_pay_week = HMRC_week_number(pay_date)
      fy = get_fy(pay_date)
      employee = timesheets.first.employee
      rate_cents = get_rate_cents(employee, timesheets.first.work_date)
      timesheets.each do |timesheet|
        # unless employee.monthly
          if !(['bonus','holiday'].include? timesheet.session)
            daily = @dailies.where(account_date: timesheet.work_date, session: timesheet.session).first
            daily_tips = (daily.tips_cents / 100.00 || 0.00)
            tips_share = daily_tips / daily.headcount.to_d
            tips += tips_share
          else
            tips_share = 0.00
            # week_wages += daily_wage
          end
          if employee.id != timesheet.employee.id
            wage = Wage.where(employee_id: employee.id, fy: fy, week_no: hmrc_pay_week).first
            unless wage
              wage = Wage.new
              wage.employee = employee
              wage.post = false if employee.monthly
              wage.fy = fy
              wage.week_no = hmrc_pay_week
              wage.rate_cents = rate_cents
            end
            wage.hours = week_hours
            wage.gross_cents = week_wages
            wage.tips_cents = week_tips * 100.00
            wage.bonus_cents = week_bonus
            wage.holiday_cents = week_holiday
            wage.save!
            wages << wage
            remove_posts(wage)
            if wage.post
              create_posts(wage)
            end
            pay_date = params[:week].to_date + 10.days
            week = week_number(pay_date) #.to_date.strftime('%U')
            hmrc_pay_week = HMRC_week_number(pay_date)
            fy = get_fy(pay_date)
            week_hours = 0
            week_wages = 0
            week_tips = 0.00
            week_bonus = 0
            week_holiday = 0
            employee = timesheet.employee
            rate_cents = get_rate_cents(timesheet.employee, timesheet.work_date)
          end
          case timesheet.session
            when 'holiday'
              week_holiday += timesheet.pay_cents
            when 'bonus'
              week_bonus += timesheet.pay_cents
            else
              hours += timesheet.hours if ['bonus','holiday'].include? session
              daily_wage = timesheet.hours * rate_cents
              week_hours += timesheet.hours
              week_wages += daily_wage
              week_tips += tips_share
          end
        end
        wage = Wage.where(employee_id: employee.id, fy: fy, week_no: hmrc_pay_week).first
        unless wage
          wage = Wage.new
          wage.employee = employee
          wage.fy = fy
          wage.week_no = hmrc_pay_week
          wage.rate_cents = rate_cents
        end
        wage.hours = week_hours
        wage.gross_cents = week_wages
        wage.tips_cents = week_tips * 100.00
        wage.bonus_cents = week_bonus
        wage.holiday_cents = week_holiday
        wage.save!
        wages << wage
        remove_posts(wage)
        if wage.post
          create_posts(wage)
        end
        wages
      end
    # end
  end

  def check_nil_cents(wage)
    wage.gross = 0.00 unless wage.gross
    wage.holiday = 0.00 unless wage.holiday
    wage.bonus = 0.00 unless wage.bonus
    wage.paye = 0.00 unless wage.paye
    wage.ni_employee = 0.00 unless wage.ni_employee
    wage.ni_employer = 0.00 unless wage.ni_employer
    wage
  end

  def remove_posts(wage)
    wage.posts.destroy_all
  end

  def create_posts(wage)
    weeks = wage.week_no - 1
    @account_date = "#{wage.fy}-04-06".to_date + (weeks * 7).days
    # wages
    wages_post(wage)
    # # tax control
    hmrc_post(wage)
    # holiday control
    holiday_post(wage) if wage.employee.holiday
    # employer costs
    payroll_cost_post(wage)
    # tips control
    tips_post(wage) if wage.tips > 0
  end

  def wages_post(wage)
    credit = true
    credit_amount = wage.gross + wage.holiday + wage.bonus - ( wage.paye + wage.ni_employee )
    debit_amount = 0.00
    account = Account.find_by_name('Wages Payable')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
    wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                       postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                       accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
  end

  def tips_post(wage)
    credit = false
    credit_amount = 0.00
    debit_amount = wage.tips
    account = Account.find_by_name('Tips Control')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
    wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                       postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                       accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)

    credit = true
    credit_amount = wage.tips
    debit_amount = 0.00
    account = Account.find_by_name('Allocated Tips')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
    wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                       postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                       accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
  end

  def hmrc_post(wage)
    if wage.paye > 0.00
      credit = true
      credit_amount = wage.paye
      debit_amount = 0.00
      account = Account.find_by_name('PAYE Control')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                         accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    if wage.ni_employee > 0.00
      credit = true
      credit_amount = wage.ni_employee
      debit_amount = 0.00
      account = Account.find_by_name('NI Employee')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                         accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    if wage.ni_employer > 0.00
      credit = true
      credit_amount = wage.ni_employer
      debit_amount = 0.00
      account = Account.find_by_name('NI Employer')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                         accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
  end

  def holiday_post(wage)
    credit = true
    credit_amount = wage.gross * CONFIG[:holiday_rate] / 100
    debit_amount = 0.00
    account = Account.find_by_name('Holiday Pay')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
    wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                       postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                       accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
  end

  def payroll_cost_post(wage)
    credit = false
    credit_amount = 0.00
    holiday_earned = wage.employee.holiday ? wage.gross * CONFIG[:holiday_rate] / 100 : 0
    debit_amount = wage.gross + wage.holiday + wage.bonus + holiday_earned + wage.ni_employer
    account = Account.find_by_name('Payroll Costs')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
    wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                       postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                       accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
  end

  def get_quantities(unit_id)
    Element.where(kind: Element.find(unit_id).name).order(:rank)
  end
  helper_method :get_quantities

end