class CartsController < ApplicationController

  include CurrentCart

  before_action :set_cart, only: [:index, :update, :destroy, :clear]

  def index
  end

  def update
    if @cart.update(cart_params)
      redirect_to @cart, notice: 'Cart was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def clear
    respond_to do |format|
      if  @cart.line_items.destroy_all
        format.js { render 'index',
                           notice: 'Cart Cleared' }
      else
        format.js { render 'index',
                           notice: 'Cart Uncleared' }
      end
    end
  end

  def destroy
    @cart.destroy
  end

  private
    # Only allow a trusted parameter "white list" through.
    def cart_params
      params[:carts]
    end
end
