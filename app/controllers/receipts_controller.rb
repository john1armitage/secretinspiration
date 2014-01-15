class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  # GET /receipts
  def index
    #@receipts = Receipt.all
    #@accounts = Account.joins(:receipts).order("name").select('name', 'accounts.id').uniq
    @banks = Bank.joins(:receipts).order("name").select('name', 'banks.id', 'rank').uniq
    @q = Receipt.search(params[:q])
    @receipts = @q.result(distinct: true).limit(99).order('receipt_date, created_at')
  end

  # GET /receipts/1
  def show
  end

  # GET /receipts/new
  def new
    @receipt = Receipt.new
    @receipt.state = 'incomplete'
    @receipt.receipt_date = cookies[:last_tx_date] || Time.now
    @receipt.amount_currency = params[:currency]
    @receipt.exchange_rate = @receipt.amount_currency == current_tenant.home_currency ? 1 : get_conversion_rate(@receipt.amount_currency, current_tenant.home_currency, 1)
    get_banks
    if params[:type].present?
      case params[:type]
        when 'directors'
          @account = 'Directors Account'
        when 'VAT'
          @account = 'VAT Control'
        when 'contra'
          @account = 'Accounts Payable'
          @receipt.receivable_type = 'Supplier'
          @receipt.receivable_id = params[:supplier_id]
          orders = Supplier.find(params[:supplier_id]).orders.where("(state = 'committed' or state = 'part_paid') and contra = true")
          amount = orders.sum('net_total_cents').to_d / 100
          @receipt.amount = amount
          @receipt.order_id = orders.first.id
          @receipt.home_amount = amount / @receipt.exchange_rate
        else
          @account = 'Retail Sales'
      end
    end
  end

  # GET /receipts/1/edit
  def edit
  end

  # POST /receipts
  def create
    @receipt = Receipt.new(params[:receipt])
    if @receipt.save
      if params[:tips].present?
        sales_apportions
        @receipt.post_takings
      else
        account_id = Account.find_by_name(params[:account]).id
        @receipt.apportions.create(receipt_id: @receipt.id, account_id: Account.find_by_name(params[:account]).id, amount_cents: @receipt.amount_cents, amount_currency: @receipt.amount_currency)
        @receipt.post
      end
      Order.find(@receipt.order_id).update(state: 'paid') unless @receipt.order_id.blank?
      @receipt.update(state: 'complete')
      cookies[:last_tx_date] = @receipt.receipt_date
      redirect_to receipts_url, notice: 'Receipt was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /receipts/1
  def update
    if @receipt.update(params[:receipt])
      redirect_to receipts_url, notice: 'Receipt was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /receipts/1
  def destroy
    @receipt.destroy
    redirect_to receipts_url, notice: 'Receipt was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt
      @receipt = Receipt.find(params[:id])
    end

    def sales_apportions
      @receipt.apportions.create(receipt_id: @receipt.id, account_id: Account.find_by_name('Retail Sales').id, amount_cents: params[:sales].to_d * 100, amount_currency: @receipt.amount_currency)
      @receipt.apportions.create(receipt_id: @receipt.id, account_id: Account.find_by_name('Tips Control').id, amount_cents: params[:tips].to_d * 100, amount_currency: @receipt.amount_currency)
      @receipt.apportions.create(receipt_id: @receipt.id, account_id: Account.find_by_name('VAT Control').id, amount_cents: params[:VAT].to_d * 100, amount_currency: @receipt.amount_currency)
    end

    def get_banks
      @banks = Bank.where( opening_balance_currency: params[:currency] ).order(:rank)
    end

  # Only allow a trusted parameter "white list" through.
    def receipt_params
      @current_resource ||= @receipt
    end
end
