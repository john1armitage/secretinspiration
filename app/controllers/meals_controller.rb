class MealsController < ApplicationController

  before_action :set_meal, only: [:show, :edit, :update, :destroy, :clear, :check_out]

  def index
    @meals = Meal.order('tabel_name')
  end

  def edit
    @meal.id
  end

  def create
    @meal = Meal.new
    @meal.seating_id = params[:seating_id] if  params[:seating_id].present?
    @meal.tabel_name = params[:tabel_name]
    @meal.save
    redirect_to meals_url
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
    order = Order.create( user_id: current_user.id, supplier_id: Supplier.find_by_name( current_tenancy.home_supplier ).id)
    @meat.line_items.update_all(ownable_type: 'Order', ownable_id: order.id)
    redirect_to order
  end

  def destroy
    @meal.destroy
    redirect_to meals_url
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
