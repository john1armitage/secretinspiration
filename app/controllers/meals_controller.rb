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
      redirect_to meals_url, notice: 'Cart was successfully updated.'
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
