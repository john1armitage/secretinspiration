class MealsController < ApplicationController

  before_action :set_meal, only: [:show, :edit, :update, :destroy, :clear, :check_out, :patcher]

  def index
  end

  def show
    if params[:takeaway].present? && @meal && @meal.line_items.size > 0
      case params[:takeaway]
        when 'cancel'
          @meal.update(state: 'takeaway', notes: '', start_time: nil)
          @meal.line_items.destroy_all
        when 'confirm'
          @meal.update(state: 'confirmed')
      end
      render  action: 'takeaway'
    end
    if params[:order].present? && params[:order] == 'all'
      @meal.update(state: 'ordered')
    end
  end



  def edit
    @meal.id
  end

  def create
    @meal = Meal.new
    if params[:takeaway].present?
      @meal.tabel_name = 'takeaway'
      @meal.state = 'confirmed'
    else
      @meal.seating_id = params[:seating_id] if  params[:seating_id].present?
      @meal.tabel_name = params[:tabel_name]
      existing = Meal.where("state = 'active' and seating_id = ?", params[:seating_id] ).size
      @meal.tabel_name += "-#{existing}" if existing > 0
      @meal.state = 'active'
    end
    @meal.start_time = Time.now
    @meal.save
    if params[:takeaway].present?
      render 'edit'
    else
      @meal.seating.booking.update_attribute(:state, 'active')
      render 'meals'
    end
  end

  def takeaway
    @meal = Meal.find(get_takeaway)
      render 'edit'
  end

  def patcher
    if params[:state].present?
      @meal.update_params(state: params[:state])
    elsif params[:takeaway].present?
      case params[:takeaway]
        when 'request'
          if @meal.update(contact: params[:contact], phone: params[:phone], start_time: params[:start_time].to_time, notes: params[:notes], state: 'requested') and 1 == 2
            TakeawayMailer.takeaway_notify(@meal).deliver
          end
        when 'cancel'
          @meal.update(notes: '', start_time: nil, state: 'takeaway')
      end
    else
      @meal.update(params[:meal])
    end
    render action: 'edit'
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
    @order.desc = @meal.seating_id.blank? ? "#{@meal.id}:#{@meal.contact}" : "#{@meal.id}:Table #{@meal.tabel_name}"
    @order.seating_id = @meal.seating_id if @meal.seating
    @order.state = 'incomplete'
    @order.save
    @meal.line_items.update_all(ownable_type: 'Order', ownable_id: @order.id)
    @meal.seating.booking.update_attribute(:state, 'billing')  if @meal.seating and @meal.seating.booking
    state = @meal.seating_id.blank? ? 'takeaway' : 'billed'
    @meal.update(state: state)
#    @meal.destroy
    set_booking_dates
    render 'check'
  end

  def check_in
    @order = Order.find(params[:id])
    @meal = Meal.find( @order.desc.split(':')[0])
    @meal.update(state: 'ordered')
    if @order.line_items.update_all(ownable_type: 'Meal', ownable_id: @meal.id)
      @order.destroy
    end
    redirect_to bookings_url()
  end


  def destroy
    @meal.destroy
    redirect_to bookings_url
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


end
