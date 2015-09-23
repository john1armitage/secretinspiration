class MealItemsController < ApplicationController

  before_action :set_meal, only: [:create, :bill, :new ]

  before_action :set_line_item, only: [ :update, :destroy ]

  def create
    if params[:line_item].present? && params[:line_item][:special].present?
      params[:choices] = 'food'
      variant = Item.find_by_name( "ad_hoc_#{params[:line_item][:special]}").variants.first
      @line_item = @meal.create_special(variant.id, params[:each], params[:line_item])
      # @line_item.save
    else
      variant = Variant.find( params[:variant_id]) # || Item.where( name: params[:commit]).first.variants.where( item_default: true).first)
      @line_item = @meal.update_variant( variant.id, params[:options] || [], params[:choices] || [] )
    end
    @line_item.domain = current_tenant.domain
    respond_to do |format|
      if !@line_item.special.blank? && @line_item.save!
        format.js { render '/meals/edit.js.erb',
                           notice: 'Line item was successfully created.' }

      elsif (current_user.id.blank? && !['takeaway','requested'].include?(@meal.state)) || @line_item.save!
        format.js { render 'meal.js.erb',
               notice: 'Line item was successfully created.' }
        format.json { render action: 'xshow',
               status: :created, location: @line_item }
      else
        format.js { render 'failed.js.erb' }
        format.json { render json: @line_item.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  def new
    @line_item = LineItem.new(special: 'starter', quantity: 1, ownable_type: 'Meal', ownable_id: params[:meal_id], variant_id: Variant.find_by_name('dummy_special').id, domain: current_tenant.domain)

  end
  # PATCH/PUT /line_items/1
  def update
    current_item = LineItem.find(params[:id])
    if params['act'] == 'add'
      @line_item = params[:option].present? ? @meal.add_option( current_item ) : @meal.add_variant( current_item )
    elsif params['act'] == 'main'
      @line_item.variant_id = Item.find_by_name( "ad_hoc_main").variants.first.id
    elsif params['act'] == 'starter'
      @line_item.variant_id = Item.find_by_name( "ad_hoc_starter").variants.first.id
    else
      @line_item = params[:option].present? ?  @meal.subtract_option( current_item ) : @meal.subtract_variant( current_item )
    end
    @line_item.save if @line_item.quantity > 0
    respond_to do |format|
      format.js { render 'meal.js.erb',
                         notice: 'Line item was successfully created.' }
      format.json { render action: 'xshow',
                           status: :created, location: @line_item }
    end
  end

  # DELETE /line_items/1
  def destroy
    if params[:option].present?
      if @line_item.is_only_child? && @line_item.parent.net_item_cents == 0
        @line_item.parent.destroy
      else
        @line_item.destroy
      end
    else
      @line_item.destroy
    end
    respond_to do |format|
      format.js { render 'meal.js.erb',
                         notice: 'Line item was successfully created.' }
      format.json { render action: 'xshow',
                           status: :created, location: @line_item }
    end
  end

  private

    def set_meal
      if current_user.id.blank?
        @meal = get_takeaway
      else
        id = params[:line_item].present? ? params[:line_item][:ownable_id] : params[:meal_id]
        @meal = Meal.find(params[:meal_id])
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
      if current_user.id.blank?
        @meal = get_takeaway
      else
        @meal = params[:option].present? ? @line_item.parent.ownable : @line_item.ownable
      end
    end

end
