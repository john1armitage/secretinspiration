class MealItemsController < ApplicationController

  before_action :set_meal, only: [:create, :bill ]

  before_action :set_line_item, only: [ :update, :destroy ]

  def create
    variant = Variant.where( name: params[:commit]).first || Item.where( name: params[:commit]).first.variants.where( item_default: true).first
    @line_item = @meal.update_variant( variant.id, params[:options] || [], params[:choices] || [] )
    @line_item.domain = current_tenant.domain
    respond_to do |format|
      if @line_item.save!
        format.js { render 'meal.js.erb',
               notice: 'Line item was successfully created.' }
        format.json { render action: 'show',
               status: :created, location: @line_item }
      else
        format.js { render 'failed.js.erb' }
        format.json { render json: @line_item.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_items/1
  def update
    current_item = LineItem.find(params[:id])
    if params['act'] == 'add'
      @line_item = @meal.add_variant( current_item )
    else
      @line_item = @meal.subtract_variant( current_item )
    end
    @line_item.save if @line_item.quantity > 0
    respond_to do |format|
      format.js { render 'meal.js.erb',
                         notice: 'Line item was successfully created.' }
      format.json { render action: 'show',
                           status: :created, location: @line_item }
    end
  end

  # DELETE /line_items/1
  def destroy
    @line_item.destroy
    respond_to do |format|
      format.js { render 'meal.js.erb',
                         notice: 'Line item was successfully created.' }
      format.json { render action: 'show',
                           status: :created, location: @line_item }
    end
  end

  private

    def set_meal
      @meal = Meal.find(params[:meal_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
      @meal = @line_item.ownable

    end
end
