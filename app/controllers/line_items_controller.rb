class LineItemsController < ApplicationController

  include CurrentCart

  before_action :set_cart, only: [:create, :update, :destroy ]

  before_action :set_line_item, only: [ :update, :destroy ]

  def create
    @line_item = @cart.update_variant(params[:variant_id])
    @line_item.domain = current_tenant.domain
    respond_to do |format|
      if @line_item.save
        format.js { render 'cart.js.erb',
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
      @line_item = @cart.add_variant( current_item )
    else
      @line_item = @cart.subtract_variant( current_item )
    end
    @line_item.save if @line_item
    respond_to do |format|
      if params[:bill].present?
        @order = @line_item.ownable
        format.js { render 'bill.js.erb',
                           notice: 'Line item was successfully created.' }
      else
        format.js { render 'cart.js.erb',
                           notice: 'Line item was successfully created.' }
      end
      format.json { render action: 'show',
                           status: :created, location: @line_item }
    end
  end

  # DELETE /line_items/1
  def destroy
    @line_item.destroy
    respond_to do |format|
      format.js { render 'cart.js.erb',
                         notice: 'Line item was successfully created.' }
      format.json { render action: 'show',
                           status: :created, location: @line_item }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
    end
end
