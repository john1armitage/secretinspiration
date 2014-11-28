class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :edit, :update, :destroy]

  # GET /payments
  def index
    @accounts = Account.joins(:payments).order("name").select('name', 'accounts.id').uniq
    @suppliers = Supplier.joins(:payments).where('payments.payable_type = ? and payments.payable_id = suppliers.id', 'Supplier').order("name").select('name', 'rank', 'suppliers.id').uniq
    @banks = Bank.joins(:payments).order("name").select('name', 'banks.id', 'rank').uniq
    @q = Payment.search(params[:q])

    unless params[:limit].present?
      limit = 25
      list_order = 'DESC'
    else
      limit = params[:limit] || 100
      list_order = 'ASC'
    end
    @payments = @q.result(distinct: true).limit(limit).order("payment_date #{list_order}, created_at")
    @payments = @payments.where('payable_type = ? and payable_id = ?', 'Supplier', params[:supplier_id]) if params[:supplier_id].present?
  end

  # GET /payments/1
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new
    @payment.state = 'uncommitted'
    @payment.payment_date = cookies[:last_tx_date] || Time.now
    @payment.bank_id = cookies[:last_tx_bank]
    @payment.account_id = cookies[:last_tx_account]

    if params[:supplier_id].present?
      get_supplier
      @payment.payable = @supplier
      @payment.amount_currency = @supplier.opening_balance_currency
      @payment.exchange_rate = @payment.amount_currency == current_tenant.home_currency ? 1 : get_conversion_rate(@payment.amount_currency, current_tenant.home_currency, 1)
      @account_type = params[:fixed].present? ? 'fixed' : 'expense'
      unless params[:quick].present?
        @payment.account_id = Account.find_by_name('Accounts Payable').id
        get_orders
      end
    end
    if params[:type].present?
      @payment.amount_currency = current_tenant.home_currency
      @payment.exchange_rate = 1
      @label = params[:type]
      case params[:type]
        when 'HMRC'
          @payment.account_id = Account.find_by_name('HMRC Control').id
          @payment.payable = Supplier.find_by_name('HMRC PAYE')
        when 'VAT'
          @payment.account_id = Account.find_by_name('VAT Control').id
          @payment.payable = Supplier.find_by_name('HMRC VAT')
        when 'payroll'
          @payment.account_id = Account.find_by_name('Payroll Costs').id
          employee = Employee.find(params[:employee_id])
          @payment.payable = employee
          @label = employee.name
      end
    else
      @label = 'Payment'
    end
    get_banks
  end

  # GET /payments/1/edit
  def edit
    @account_type = @payment.account.root.name == 'Asset' ? 'Fixed' : 'Expense'
    get_banks
  end

  # POST /payments
  def create
    Payment.transaction do
      @payment = Payment.create(params[:payment])
      if @payment
        if params[:order_id].present?
          i = 0
          0.upto( params[:order_id].size - 1 ) do
            if params[:amount][i].to_d > 0
              @payment.allocations.create( payment_id: @payment.id, order_id: params[:order_id][i], amount: params[:amount][i] )
              @order = Order.find(params[:order_id][i])
              @order.paid_cents = @order.allocations.sum(:amount_cents)
              #p @order.paid_cents
              #p (@order.net_total_cents + @order.tax_total_cents)
              #p  ( @order.paid_cents < (@order.net_total_cents + @order.tax_total_cents) )
              @order.state = ( @order.paid_cents < (@order.net_total_cents + @order.tax_total_cents) ) ? 'part_paid' : 'paid'
              @order.save
            end
            i += 1
          end
        elsif params[:paye].present? or params[:payroll].present?
          ni_employee = params[:ni_employee].to_d
          ni_employer = params[:ni_employer].to_d
          paye = params[:paye].to_d
          if params[:gross].present?
            tips = params[:tips].to_d
            @payment.payroll_postings( ni_employee, ni_employer, paye, tips )
          else
            @payment.hmrc_postings( ni_employee, ni_employer, paye )
          end
        elsif params[:vat].present?
          net = params[:net].to_d
          vat = params[:vat].to_d
          @payment.quick_postings( net, vat )
        end
        @payment.update( state: 'committed' )
        @payment.postings unless params[:vat].present?
        cookies[:last_tx_date] = @payment.payment_date
        cookies[:last_tx_bank] = @payment.bank_id
        cookies[:last_tx_account] = @payment.account_id
        if @payment.payable_type == 'Supplier'
          redirect_to suppliers_url
          #redirect_to new_payment_url(supplier_id: @payment.payable_id, quick: true ), notice: 'Payment was successfully created.'
        elsif @payment.payable_type == 'Employee'
          redirect_to employees_url
          # redirect_to new_payment_url(employee_id: @payment.payable_id, quick: true ), notice: 'Payment was successfully created.'
        else
          redirect_to payments_url
        end
      else
        render action: 'new'
      end
    end
  end


  # PATCH/PUT /payments/1
  def update
    if @payment.update(params[:payment])
      @payment.transaction do
        @payment.update( payment_date: params[:payment][:payment_date], supplier_name: params[:payment][:supplier_name],
                         desc: params[:payment][:desc], notes: params[:payment][:notes] )
        Posting.where( postable: @payment).each do |posting|
          posting.update(event_date: @payment.payment_date, accountable_id: @payment.payable_id)
        end
      end
      redirect_to payments_url, notice: 'Payment was successfully updated.'
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
    def order_payment

    end

    def HMRC_payment

    end

    def vanilla_payment

    end
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
      if @supplier
        @banks = Bank.where( opening_balance_currency: @supplier.opening_balance_currency ).order(:rank)
      else
        @banks = Bank.where( opening_balance_currency: current_tenant.home_currency ).order(:rank)
      end

    end

    def current_resource
      @current_resource ||= @payment
    end

end
