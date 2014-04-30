class CartsController < ApplicationController

  include CurrentCart

  before_action :set_cart, only: [:index, :update, :show, :destroy, :clear, :check_out]

  def index
    if params[:cart_id].present?
      @page = Page.find_by_code(current_tenant.default_category)
    elsif params[:code].present?
      @page = Page.find_by_code(params[:code])
    end
  end

  def update
    if @cart.update(cart_params)
      redirect_to @cart, notice: 'Cart was successfully updated.'
    else
      render action: 'edit'
    end
  end

  #def clear
  #  respond_to do |format|
  #    if  @cart.line_items.destroy_all
  #      format.js { render 'index',
  #                         notice: 'Cart Cleared' }
  #    else
  #      format.js { render 'index',
  #                         notice: 'Cart Uncleared' }
  #    end
  #  end
  #end

  def clear
    if  @cart.line_items.destroy_all
      render 'line_items/cart.js.erb'
    else
      render 'line_items/cart.js.erb'
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
    @order.net_total_cents = @order.net_home_cents = @cart.line_items.map(&:net_total_item_cents).sum
    @order.tax_total_cents = @order.tax_home_cents = @cart.line_items.map(&:tax_total_item_cents).sum
    @order.effective_date = Time.now
    @order.desc = "Wish List #{Time.now}"
    @order.state = 'incomplete'
    @order.save
    @cart.line_items.update_all(ownable_type: 'Order', ownable_id: @order.id)
    #redirect_to carts_url(cart_id: @cart.id, bill: true)
    #redirect_to orders_url(home: true)
  end

  def check_in
    @cart = Cart.create( user_id: current_user.id)
    @order = Order.find(params[:id])
    if @order.line_items.update_all(ownable_type: 'Cart', ownable_id: @cart.id)
      @order.destroy
    end
    redirect_to carts_url(cart_id: @cart.id)
    #respond_to do |format|
    #   format.js  { render action: 'index', cart_id: @cart.id} # renders create.js.erb, which could be used to redirect via javascript
    #end
  end

  def destroy
    @cart.destroy
    set_cart
    render 'index'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def cart_params
      params[:carts]
    end
end
