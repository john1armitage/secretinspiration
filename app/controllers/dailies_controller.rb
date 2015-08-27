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
      daily_processed
      redirect_to dailies_url(daily_date: @daily.account_date.beginning_of_month.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
      # redirect_to daily_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
    else
      render action: 'form'
    end
  end

  # PATCH/PUT /dailies/1
  def update
    set_net
    if @daily.update(params[:daily])
      remove_financials
      create_financials
      daily_processed
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
    def daily_processed
      @daily.update(processed: true)
    end
    def remove_financials
      @daily.posts.destroy_all
      # @daily.posts.each do |financial|
      #   financial.destroy
      # end
    end
    def create_financials
      # card control
      credit_card_financial
      # cash control
      cash_financial
      # VAT control
      tax_financial
      # sales control
      sales_financial
      # tips control
      tips_financial
    end
    def credit_card_financial
      ref_bank = 'MERCHANT'
      bank = Bank.find_by_reference(ref_bank)
      credit = false
      credit_amount = 0.00
      debit_amount = @daily.credit_card
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('Merchant Control')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}" # 'Daily Credit Card Receipt'
      @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                           postable_id: @daily.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                           accountable_type:'Bank', accountable_id:bank.id, grouping: account.grouping)
      # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end
    def cash_financial
      ref_bank = 'CASH'
      bank = Bank.find_by_reference(ref_bank)
      credit = false
      credit_amount = 0.00
      debit_amount = @daily.take - @daily.credit_card
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('Cash in Hand')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
      @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                           postable_id: @daily.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                           accountable_type:'Bank', accountable_id:bank.id, grouping: account.grouping)
      # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end
    def sales_financial
      ref_bank = 'RECEIVABLE'
      bank = Bank.find_by_reference(ref_bank)
      credit = true
      credit_amount = @daily.turnover # - (@daily.tax + @daily.tips)
      debit_amount = 0.00
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('Sales')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
      @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                           postable_id: @daily.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                           accountable_type:'Bank', accountable_id:bank.id, grouping: account.grouping)
      # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end
    def tax_financial
      ref_bank = 'VAT'
      bank = Bank.find_by_reference(ref_bank)
      credit = true
      credit_amount = @daily.tax
      debit_amount = 0.00
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('VAT Control')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
      @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                           postable_id: @daily.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                           accountable_type:'Bank', accountable_id:bank.id, grouping: account.grouping)
      # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end
    def tips_financial
      ref_bank = 'TIPS'
      bank = Bank.find_by_reference(ref_bank)
      credit = true
      credit_amount = @daily.tips
      debit_amount = 0.00
      entity = 'Account'
      type = 'sales'
      account = Account.find_by_name('Tips Control')
      if account
        entity_id = account.id
        entity_ref = account.code
      end
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
      @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                           postable_id: @daily.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                           accountable_type:'Bank', accountable_id:bank.id, grouping: account.grouping)
      # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
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
