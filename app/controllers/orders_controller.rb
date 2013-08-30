class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :commit, :pay]

  # GET /orders
  def index
    unless params[:supplier_id].present?
      if params[:home].present?
        @orders = Supplier.find_by_name( current_tenant.home_supplier ).orders.order(:effective_date => :desc, :net_total_cents => :desc )
      else
        @orders = Order.outgoings(Supplier.find_by_name( current_tenant.home_supplier )).order(:effective_date => :desc, :net_total_cents => :desc )
      end
    else
      @supplier = Supplier.find(params[:supplier_id])
      @orders = @supplier.orders.order(:effective_date => :desc, :net_total_cents => :desc )
    end
  end

  # GET /orders/1
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.user = current_user
    @order.state = 'incomplete'
    @order.effective_date = cookies[:last_tx_date] || Time.now
        if params[:supplier_id].present?
      @order.supplier = Supplier.find(params[:supplier_id])
      @order.supplier_name = @order.supplier.name
      get_items
    end
    @type = params[:type].present? ? params[:type] : nil
    @order.contra = true if params[:contra].present?
    if params[:quick].present?
      @order.quick = true
      @currency = @order.supplier ? @order.supplier.opening_balance_currency : current_tenant.home_currency
    elsif params[:currency].present?
        @currency = params[:currency]
    else
      @currency =  @order.supplier ? @order.supplier.opening_balance_currency :  current_tenant.home_currency
    end
    if @currency == current_tenant.home_currency
      @exchange_rate = 1
    else
      @exchange_rate = get_conversion_rate(@currency, current_tenant.home_currency, 1)
    end
    @order.net_total_currency = @currency
    @order.exchange_rate = @exchange_rate
  end

  # GET /orders/1/edit
  def edit
    get_items
  end

  # POST /orders
  def create
    @order = Order.new(params[:order].merge(net_total_currency: current_tenant.home_currency))
    cookies[:last_tx_date] = @order.effective_date

    if @order.save
      redirect_to orders_url(supplier_id: @order.supplier_id), notice: 'Order was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(params[:order])
      redirect_to orders_url(supplier_id: @order.supplier_id), notice: 'Order was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def commit
    #@order.update(state: 'committed')
    if @order.supplier == Supplier.find_by_name( current_tenant.home_supplier )
      @order.contra = true
    end
    @order.commit
    @order.save
    redirect_to orders_url(supplier_id: @order.supplier_id)
  end

  def pay
    @order.pay
    @order.save
    redirect_to orders_url(supplier_id: @order.supplier_id)
  end


  # DELETE /orders/1
  def destroy
    @order.destroy
    redirect_to orders_url(home: @order.home_supplier), notice: 'Order was successfully destroyed.'
  end

  private
    def get_items
      @items = @order.supplier.items.where("product_flow <> 'outgoing'").map {|i| i.name}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

  def current_resource
    @current_resource ||= @order
  end
end
