class DailiesController < ApplicationController
  before_action :set_daily, only: [:show, :edit, :form, :update, :destroy]

  # GET /dailies
  def index
    if params[:balance].present?
      render 'balance'
    else
      set_daily_dates
    end
  end

  # GET /dailies/1
  def show
  end

  # GET /dailies/new
  def new
    @daily = Daily.new
    @daily.account_date = params[:date].present? ? params[:date] : Date.today
    @daily.session = 'dinner'
    @daily.headcount = get_headcount
    get_credit_card
    get_daily_orders
    render 'form'
  end

  def edit
    @daily.headcount = get_headcount
    get_credit_card
    get_daily_orders
    render 'form'
  end
  # GET /dailies/1/edit
  def form
    @daily.headcount = get_headcount
    render 'form'
  end

  # POST /dailies
  def create
    @daily = Daily.new(params[:daily])
    set_net
    if @daily.save
      create_financials
      redirect_to dailies_url(daily_date: @daily.account_date.beginning_of_month.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
      # redirect_to daily_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
    else
      render action: 'form'
    end
  end

  # PATCH/PUT /dailies/1
  def update
    set_net
    remove_financials
    create_financials
    if @daily.update(params[:daily])
      redirect_to dailies_url(daily_date: @daily.account_date.beginning_of_month.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
      # redirect_to daily_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully updated.'
    else
      render action: 'form'
    end
  end

  # DELETE /dailies/1
  def destroy
    params[:daily_date] = @daily.account_date.beginning_of_month.strftime('%d-%m-%Y')
    @daily.destroy
    set_daily_dates
    render 'index'
#    redirect_to dailies_url, notice: 'Daily was successfully destroyed.'
  end

  private
    def remove_financials
      @daily.financials.destroy
    end
    def create_financials
      # card control
      credit_card_financial
      # cash control
      cash_financial
      # VAT control
      # income control
      # tips control
    end
    def credit_card_financial
      ref_bank = 'MERCHANT'
      credit = true
      credit_amount = @daily.credit_card
      debit_amount = 0
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('Accounts Receivable')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      summary = desc = "#{account.name} #{credit ? 'credit' :'debit'} into #{ref_bank}"
      @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end
    def cash_financial
      ref_bank = 'CASH'
      credit = true
      credit_amount = @daily.credit_card
      debit_amount = 0
      entity = 'Account'
      type = 'takings'
      account = Account.find_by_name('Accounts Receivable')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      summary = desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
      @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end
    def sales_financial
      ref_bank = 'RECEIVABLE'
      credit = false
      credit_amount = 0
      debit_amount = @daily.turnover
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('Sales')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      summary = desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
      @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end
    def tax_financial
      ref_bank = 'RECEIVABLE'
      credit = false
      credit_amount = 0
      debit_amount = @daily.turnover
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('VAT Control')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      summary = desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
      @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end
    def tips_financial
      ref_bank = 'RECEIVABLE'
      credit = false
      credit_amount = 0
      debit_amount = @daily.turnover
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('Tips Control')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      summary = desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
      @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end


    def set_net
      gross = params[:gross].present? ? params[:gross].to_d : 0.00
      if gross > 0
        vat_rate = current_tenant.vat_exempt ? 0.00 : CONFIG[:vat_rate_standard].to_d
        tax = ((gross - ( gross / (1.00 + vat_rate) )) * 100 ).to_i
        net = (gross * 100 - tax).to_i
        tips =  (params[:daily][:tips].to_d * 100).to_i
        @daily.update( turnover_cents: net, tax_cents: tax, take_cents: (net + tax + tips))
      end
    end

    def set_daily
      @daily = Daily.find(params[:id])
    end

  def get_credit_card
    @credit_card = Order.where('effective_date = ? AND session = ?', @daily.account_date, @daily.session).to_a.sum(&:credit_card_cents)
  end

  def get_daily_orders
    @orders = Order.where(session: @daily.session, effective_date: @daily.account_date)
  end
    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @daily
  end
end
