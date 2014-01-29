class MealsController < ApplicationController

  before_action :set_meal, only: [:show, :edit, :update, :destroy, :clear, :check_out]

  def index
  end

  def edit
    @meal.id
  end

  def create
    @meal = Meal.new
    @meal.seating_id = params[:seating_id] if  params[:seating_id].present?
    @meal.tabel_name = params[:tabel_name]
    @meal.save
    render 'meals'
  end

  def update
    if @meal.update(meal_params)
      redirect_to meals_url, notice: 'Meal was successfully updated.'
    else
      render action: 'edit'
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
    @order.effective_date = Time.now
    @order.desc = "Table #{@meal.tabel_name}"
    @order.state = 'incomplete'
    @order.save
    @meal.update( state: 'checkout')
    @meal.line_items.update_all(ownable_type: 'Order', ownable_id: @order.id)
    Meal.find(@meal.id).destroy
    set_booking_dates
    render 'check'
  end

  def check_in
    @order = Order.find(params[:id])
    @meal = Meal.create( tabel_name: @order.desc.gsub(/Table /,''))
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
      @meal = Meal.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def meal_params
      params[:meals]
    end
end
