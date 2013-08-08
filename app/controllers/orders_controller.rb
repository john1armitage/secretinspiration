class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  def index
    @orders = Order.order(:effective_date => :desc, :net_total_cents => :desc )
  end

  # GET /orders/1
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.user = current_user
    @order.state = 'incomplete'
    if params[:quick].present?
      @order.quick = true
      @currency = current_tenant.home_currency
    else
      @currency = params[:currency]
      @exchange_rate = get_conversion_rate(@currency,current_tenant.home_currency, 1) unless @currency == current_tenant.home_currency
    end
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  def create
    @order = Order.new(params[:order])

    if @order.save
      redirect_to @order, notice: 'Order was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(params[:order])
      redirect_to @order, notice: 'Order was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy
    redirect_to orders_url, notice: 'Order was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

  def current_resource
    @current_resource ||= @order
  end
end
