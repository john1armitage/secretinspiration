class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :edit, :update, :destroy]

  # GET /payments
  def index
    @payments = Payment.all
  end

  # GET /payments/1
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new
    @payment.state = 'uncommitted'
    @payment.payment_date = cookies[:last_tx_date] || Time.now
    get_supplier
    @payment.payable = @supplier
    @payment.account_id = Account.find_by_name('Accounts Payable').id
    @payment.amount_currency = @supplier.opening_balance_currency
    @payment.exchange_rate = @payment.amount_currency == current_tenant.home_currency ? 1 : get_conversion_rate(@payment.amount_currency, current_tenant.home_currency, 1)
    get_orders
    get_banks
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  def create
    Payment.transaction do
      if @payment = Payment.create(params[:payment])
        @payment.update( state: 'committed' )
        i = 0
        0.upto( params[:order_id].size - 1 ) do
          if params[:amount][i].to_d > 0
            @payment.allocations.create( payment_id: @payment.id, order_id: params[:order_id][i], amount: params[:amount][i] )
            @order = Order.find(params[:order_id][i])
            @order.paid_cents = @order.allocations.sum(:amount_cents)
            p @order.paid_cents
            p (@order.net_total_cents + @order.tax_total_cents)
            p  ( @order.paid_cents < (@order.net_total_cents + @order.tax_total_cents) )
            @order.state = ( @order.paid_cents < (@order.net_total_cents + @order.tax_total_cents) ) ? 'part_paid' : 'paid'
            @order.save
          end
          i += 1
        end
        redirect_to suppliers_url, notice: 'Payment was successfully created.'
      else
        render action: 'new'
      end
    end
  end

  # PATCH/PUT /payments/1
  def update
    if @payment.update(params[:payment])
      redirect_to @payment, notice: 'Payment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /payments/1
  def destroy
    @payment.destroy
    redirect_to payments_url, notice: 'Payment was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def get_supplier
      @supplier = Supplier.find(params[:supplier_id])
    end

    def get_orders
      @orders = @supplier.orders.where( "state = 'committed' or state = 'part_paid'" ).order(:effective_date, :id)
    end

    def get_banks
      @banks = Bank.where( opening_balance_currency: @supplier.opening_balance_currency ).order(:rank)
    end

    def current_resource
      @current_resource ||= @payment
    end

end
