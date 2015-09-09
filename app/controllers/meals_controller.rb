class MealsController < ApplicationController

#  include ActionController::Live

  before_action :set_meal, only: [:show, :edit, :update, :destroy, :clear, :check_out, :patcher]

  def index
    if params[:monitor].present?
      if params[:meal_id].present?
        meal = Meal.find(params[:meal_id])
        target = meal.seating_id.blank? ? "Take #{meal.id}" : "#{meal.tabel_name}"
        @message = Message.new(message: "#{target}: #{meal.state.gsub(/_/,' ')}", message_type: meal.state.gsub(/\w*_/,''), user_id: current_user.id, created_at: Time.now)
      end
      get_meals
      render 'monitor', layout: 'monitor'
    elsif params[:table_view].present?
      @booking_date = Date.today
      @bookings = Booking.where( booking_date: @booking_date )
      @table_view = true
      render 'index', layout: 'table_view'
    end
  end

  def show
    if params[:takeaway].present? && @meal
      case params[:takeaway]
        when 'cancel'
          @meal.line_items.destroy_all
          @meal.update(state: 'takeaway', notes: '', start_time: nil)
        when 'confirm'
          state = 'confirmed'
          @meal.timings.create(state: state)
          @meal.update(state: state) if @meal.line_items
      end
      render  action: 'takeaway'
    end
    if params[:order].present? # && params[:order] == 'all'
      @meal.update(ordered_at: Time.now)
      if @meal.seating_id.blank?
        if @meal.line_items.size > 0
          state = 'ordered'
          target = @meal.seating_id.blank? ? "Take #{@meal.id}" : "#{@meal.tabel_name}"
          @message = Message.new(message: "#{target}: #{state.gsub(/_/,' ')}", message_type: state, user_id: current_user.id, created_at: Time.now)
        else
          @no_line_item = true
        end
      else
        courses = get_courses
        if params[:order] == 'dessert' && courses.include?('dessert')
          state = 'dessert'
        elsif courses.include?('starter')
          state = 'starter'
        elsif courses.include?('main')
          state = 'main'
        end
        target = @meal.seating_id.blank? ? "Take #{@meal.id}" : "#{@meal.tabel_name}"
        @message = Message.new(message: "#{target}: #{state.gsub(/_/,' ')}", message_type: state, user_id: current_user.id, created_at: Time.now)
      end
      if state
        #EventBus.announce( :order_update, meal: @meal.id)
        @meal.ordered_at = Time.now if @meal.ordered_at.blank? || params[:order] == 'dessert'
        @meal.timings.create(state: state)
        @meal.update(state: state)
      end
    end
  end

  def edit
    # @meal.id
    render 'takeaway' if params[:choice].present?
  end

  def create
    @meal = Meal.new
    if params[:takeaway].present?
      @meal.tabel_name = 'takeaway'
      @meal.state = 'confirmed'
    else
      @meal.seating_id = params[:seating_id] if  params[:seating_id].present?
      @meal.tabel_name = params[:tabel_name]
      existing = Meal.where("state <> 'billed' and seating_id = ?", params[:seating_id] ).size
      @meal.tabel_name += "-#{existing}" if existing > 0
      state = 'active'
      @meal.state = state
    end
    @meal.start_time = Time.now
    @meal.save
    @meal.timings.create(state: state)
    target = @meal.seating_id.blank? ? "Take #{@meal.id}" : "#{@meal.tabel_name}"
    @message = Message.new(message: "#{target}: ordering", message_type: @meal.state, user_id: current_user.id, created_at: Time.now)
    if params[:takeaway].present?
      render 'edit'
    else
      @meal.seating.booking.update_attribute(:state, 'active')
      render 'meals'
    end
  end

  def takeaway
    @meal = Meal.find(get_takeaway)
    render 'edit'       # 'edit'
  end

  def patcher
    if params[:state].present?
      @meal.update(ordered_at: Time.now) unless params[:state].include? 'ready'
      if params[:state].include? 'complete'
        courses = get_courses
        case get_current_course(params[:state])
          when 'starter'
            state = courses.include?('main') ? 'main' : courses.include?('dessert') ? 'dessert' : 'complete'
          when 'main'
            state = courses.include?('dessert') ? 'dessert' : 'complete'
          when 'dessert'
            state = 'complete'
        end
      else
        state = params[:state]
      end
      #Publish events
      @meal.timings.create(state: state)
      @meal.update(state: state)
    elsif params[:pholourie].present?
      @meal.timings.create(state: 'pholourie')
      @meal.update(pholourie: true)
    elsif params[:takeaway].present?
      case params[:takeaway]
        when 'request'
          if @meal.update(state: 'requested')
            @meal.timings.create(state: 'requested')
            TakeawayMailer.takeaway_notify(@meal).deliver
          else
            render 'takeaway'
          end
        when 'cancel'
          @meal.timings.create(state: 'takeaway')
          @meal.update(notes: '', start_time: nil, state: 'takeaway')
      end
    else
      @meal.update(params[:meal])
    end
    if params[:monitor].present?
      redirect_to meals_url(monitor: true, meal_id: @meal.id )
    else
      render action: 'edit'
    end
  end

  def update
    if @meal.update(params[:meal])
      render 'edit' #redirect_to meals_url, notice: 'Meal was successfully updated.'
    else
      render 'edit'
    end
  end

  def clear
    if  @meal.line_items.destroy_all
      target = @meal.seating_id.blank? ? "Take #{@meal.id}" : "#{@meal.tabel_name}"
      @message = Message.new(message: "#{target}: re-ordering", message_type: @meal.state, user_id: current_user.id, created_at: Time.now)
      state = @meal.seating_id.blank? ? 'takeaway' : 'active'
      @meal.update(state: state)
      @meal.timings.create(state: state)
      render 'meal_items/meal.js.erb'
    else
      render 'meal_items/meal.js.erb'
    end
  end

  def check_out
    @order = Order.new
    @order.user_id = current_user.id
    @order.supplier = Supplier.find_by_name( current_tenant.home_supplier )
    @order.account = Account.find_by_name("Sales")
    @order.home_supplier = true
    @order.net_total_currency = @order.supplier.opening_balance_currency
    @order.exchange_rate = 1
    @order.net_total_cents = @order.net_home_cents = @meal.line_items.map(&:net_total_item_cents).sum
    @order.tax_total_cents = @order.tax_home_cents = @meal.line_items.map(&:tax_total_item_cents).sum
    if params[:offer]
      discount = 0.00
      params[:offer].each do |k, v|
        discount += v.to_d
      end
      @order.discount = discount
      net_discount = current_tenant.vat ? @order.discount / (1 + CONFIG[:vat_rate_standard].to_d ) : 0
      net_discount_tax = @order.discount - net_discount
      @order.net_home -= net_discount
      @order.tax_home -= net_discount_tax
      @order.net_total = @order.net_home
      @order.tax_total = @order.tax_home
    end
    if @meal.seating_id.blank? && (@order.net_home + @order.tax_home) > CONFIG[:takeaway_threshold].to_d
      @order.discount = (@order.net_home + @order.tax_home) * CONFIG[:takeaway_discount]
      net_discount = current_tenant.vat ? @order.discount / (1 + CONFIG[:vat_rate_standard].to_d ) : 0
      net_discount_tax = @order.discount - net_discount
      @order.net_home -= net_discount
      @order.tax_home -= net_discount_tax
      @order.net_total = @order.net_home
      @order.tax_total = @order.tax_home
    end
    @order.seating = @meal.seating
    @order.effective_date = Time.now
    @order.desc = @meal.seating_id.blank? ? "#{@meal.id}:TA#{@meal.id} #{@meal.contact}" : "#{@meal.id}:Table #{@meal.tabel_name}/#{@meal.seating.booking.pax}"
    @order.seating_id = @meal.seating_id if @meal.seating
    @order.state = 'incomplete'
    @order.save
    @order.state = 'complete'
    @meal.line_items.update_all(ownable_type: 'Order', ownable_id: @order.id)
    @meal.timings.update_all(timeable_type: 'Order', timeable_id: @order.id)
    @meal.seating.booking.update_attribute(:state, 'billing')  if @meal.seating and @meal.seating.booking
    state = @meal.seating_id.blank? ? 'takeaway' : 'billed'
    @meal.update(state: state)
    @order.timings.create(state: state)
#    @meal.destroy
    set_booking_dates
    target = @meal.seating_id.blank? ? "Take #{@meal.id}" : "#{@meal.tabel_name}"
    state = @meal.seating ? state.gsub(/_/,' ') : 'billed'
    @message = Message.new(message: "#{target}: #{state}", message_type: state, user_id: current_user.id, created_at: Time.now)
    render 'check'
  end

  def check_in
    @order = Order.find(params[:id])
    @meal = Meal.find( @order.desc.split(':')[0])
    state = @meal.seating_id.blank? ? 'checkout' : 'ordered'
    @meal.update(state: state)
    if @order.line_items.update_all(ownable_type: 'Meal', ownable_id: @meal.id) && @order.timings.update_all(timeable_type: 'Meal', timeable_id: @meal.id)
      @meal.timings.create(state: 'unbilled')
      @order.destroy
    end
    redirect_to bookings_url
  end


  def destroy
    target = @meal.seating_id.blank? ? "Take #{@meal.id}" : "#{@meal.tabel_name}"
    unless @meal.seating_id.blank?
      @meal.seating.booking.update(state: 'incomplete')
    end
    target = @meal.seating_id.blank? ? "Take #{@meal.id}" : "#{@meal.tabel_name}"
    message = "#{target}:cancel"
    @meal.destroy!
    redirect_to bookings_url(message: message, target: target)
  end

  private

  def set_meal
      if current_user.id.blank?
        @meal = get_takeaway
      else
        @meal = Meal.find(params[:meal_id].present? ? params[:meal_id] : params[:id] )
      end
    end

    # Only allow a trusted parameter "white list" through.
    def current_resource
      @current_resource ||= @meal
    end

    def get_courses
      courses = []
      line_items = @meal.line_items.joins( {variant: { item: {category: :root } } }).where("roots_categories.name = 'food'").each do |line_item|
        courses << line_item.variant.item.grouping.split(':')[1]
      end
      courses.uniq
    end

    def get_current_course(state)
      state.gsub(/_/,'').gsub(/ready/,'').gsub(/served/,'').gsub(/complete/,'')
    end

end
