class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :commit, :pay, :status]

  # GET /orders

  def index
    @suppliers = Supplier.order(:name)
    @q = Order.search(params[:q])

    unless params[:limit].present?
      limit = 25
      list_order = 'DESC'
    else
      limit = params[:limit] || 500
      list_order = 'ASC'
    end
    @orders = @q.result(distinct: true).limit(limit).order("effective_date #{list_order}, net_total_cents DESC")

    if params[:supplier_id].present?
      @supplier = Supplier.find(params[:supplier_id])
      @orders = @orders.where( supplier_id: params[:supplier_id] ) #@supplier.orders.search(params[:q]).result(distinct: true).order("effective_date #{list_order}, net_total_cents DESC").limit(limit)
    else
      if params[:home].present?
        @orders = @orders.where(supplier_id: current_tenant.supplier_id) #.    orders.search(params[:q]).result(distinct: true).limit(limit).order("effective_date #{list_order}, net_total_cents DESC" )
      else
        @orders = @orders.outgoings(Supplier.find_by_name( current_tenant.home_supplier )) #.search(params[:q]).result(distinct: true).limit(limit).order("effective_date #{list_order}, net_total_cents DESC")
      end
    end
    @orders = @orders.where(effective_date: params[:date]) if params[:date].present?
  end

  def analysis
    set_analysis_dates
    choices = params[:choices].present? ? params[:choices] : 'food'
    root_id = Category.find_by_name(choices)
    params[:cat] == Category.find_by_name( (params[:choices] == 'food') ? 'main' : 'wines') if ( params[:cat].blank? or !params[:cat].present?)
    @cats = collection_to_options(get_categories(choices))
    @subs = collection_to_options(Category.find(params[:cat]).children) if params[:cat].present?
    @items = collection_to_options(Item.where(category: params[:sub])) if params[:sub].present?
    # if params[:cat].blank? and params[:sub].blank? and params[:item].blank?
    # @orders = Order.where('effective_date = ? ', @start).includes( line_items: [ variant: [item: :category]]).order("categories.rank")
    # param = (@start = @stop ) ? "'effective_date = ? ', @start" : "'effective_date >= ? and effective_date <= ?', @start, @stop"
    @orders = Order.where('effective_date >= ? and effective_date <= ?', @start, @stop).includes( line_items: [ variant: [item: :category]]).order("categories.rank")
    # else
    @line_items = LineItem.where('line_items.created_at >= ? and line_items.created_at <= ? and line_items.domain = ? and root_id = ?', @start.beginning_of_day, @stop.end_of_day, current_tenant.domain, root_id).includes( variant: [item: :category]).order("categories.rank, items.rank")
    if !params[:item].blank?
      @line_items = @line_items.where( 'items.id = ?', params[:item] )
    elsif !params[:sub].blank?
      @line_items = @line_items.where( 'categories.id = ?', params[:sub] )
    elsif !params[:cat].blank?
      @line_items = @line_items.where( 'categories.category_id = ?', params[:cat] )
    end
    render 'analysis', layout: nil
  end

  # GET /orders/1
  def show
    if params[:bill].present?
      @order.state = 'complete'
      @order.paid = @order.net_home + @order.tax_home unless @order.paid > 0
    end
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.user = current_user
    @order.state = 'incomplete'
    @order.account_id = cookies[:last_tx_account]
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
    @order.cheque = @order.goods = @order.cash = @order.voucher = 0.00
  end

  # GET /orders/1/edit
  def edit
    get_items
  end

  # POST /orders
  def create
    @order = Order.new(params[:order].merge(net_total_currency: current_tenant.home_currency))
    cookies[:last_tx_date] = @order.effective_date
    cookies[:last_tx_account] = @order.account_id

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
    unless @order.contra
      @order.pay
      @order.save
    else
      @order.contra
      @order.save
    end

    redirect_to orders_url(supplier_id: @order.supplier_id)
  end
  def status
    if params[:status].present?
      @order.update_attribute(:state, params[:status])
    elsif params[:order].present?

      @order.update(params[:order])

      net_home = @order.paid / (1 + CONFIG[:vat_rate_standard])
      tax_home = @order.paid - net_home

      @order.update(net_home: net_home, tax_home: tax_home)
      @order.timings.create(state: @order.state)

      # if @order.goods > 0
      #   @order.paid = @order.paid - @order.goods
      #   @order.save
      # end
      # if @order.voucher > 0
      #   @order.net_home = (@order.paid / 1.2)
      #   @order.tax_home = (@order.paid - @order.net_home)
      #   @order.save
      # end
      # @order.update(tip_cents: 0) if @order.tip_cents.blank?
    end
    set_booking_dates
    render 'bookings/index'
  end

  # DELETE /orders/1
  def destroy
    supplier_id = @order.supplier_id
    if params[:test].present?
      @order.update_attribute(:state, 'test')
    else
      # @items.variants.where("item_id = ? AND domain = ?", @item_id, current_tenant.domain).destroy
      @order.line_items.where(ownable_type: 'Order', ownable_id: @order.id, domain: current_tenant.domain).destroy_all
      @order.destroy
    end
    if supplier_id == Supplier.find_by_name(current_tenant.home_supplier ).id
      render :nothing => true
    else
      redirect_to orders_url(supplier_id: supplier_id)
    end
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
