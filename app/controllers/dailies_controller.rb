class DailiesController < ApplicationController
  before_action :set_daily, only: [:show, :edit, :form, :update, :destroy]

  # GET /dailies
  def index
    if params[:balance].present?
      render 'balance'
    else
      set_daily_dates
    end
    if params[:orders].present?
      @orders = Order.where(supplier_id: current_tenant.supplier_id, effective_date: params[:orders], state: 'complete').order('effective_date DESC')
      @origin = 'dailies'
      render 'orders.js.erb'
    end
  end

  # GET /dailies/1
  def show
  end

  # GET /dailies/new
  def new
    if params[:date].present? && params[:session].present?
      @daily = Daily.where(account_date: params[:date], session: params[:session]).first
    end
    unless @daily
      @daily = Daily.new
      @daily.account_date = params[:date].present? ? params[:date] : Date.today
      @daily.session = params[:session].present? ? params[:session] : 'dinner'
      @daily.cash = 0.00
    end
    get_orders_summary
    @daily.headcount = get_headcount
    render 'form'
  end

  def edit
    @daily.headcount = get_headcount
    get_orders_summary
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
    # set_net
    if @daily.save!
      create_posts
      daily_processed
      redirect_to dailies_url(daily_date: @daily.account_date.beginning_of_month.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
      # redirect_to daily_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
    else
      render action: 'form'
    end
  end

  # PATCH/PUT /dailies/1
  def update
    # set_net
    if @daily.update(params[:daily])
      remove_posts
      create_posts
      daily_processed
      redirect_to dailies_url(daily_date: @daily.account_date.beginning_of_month.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
      # redirect_to daily_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully updated.'
    else
      render action: 'form'
    end
  end

  # DELETE /dailies/1
  def destroy
    remove_posts
    params[:daily_date] = @daily.account_date.beginning_of_month.strftime('%d-%m-%Y')
    @daily.destroy
    set_daily_dates
    render 'index'
  end

  private
    def daily_processed
      @daily.update(processed: true)
    end
    def remove_posts
      @daily.posts.destroy_all
    end
    def create_posts
      # card control
      credit_card_post if @daily.credit_card > 0
      # cash control
      cash_post if @daily.cash > 0
      # cheque control
      cheque_post if @daily.cheque > 0
      # goods control
      goods_post if @daily.goods > 0
      # VAT control
      vat_post if @daily.tax > 0
      # sales control
      net_sales_post if @daily.turnover > 0
      # tips control
      tips_post if @daily.tips > 0
    end
    def credit_card_post
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
                           accountable_type:'Bank', accountable_id:bank.id, grouping_id: account.grouping_id)
      # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end

    def cash_post
      ref_bank = 'CASH'
      bank = Bank.find_by_reference(ref_bank)
      credit = false
      credit_amount = 0.00
      debit_amount = @daily.cash
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
                           accountable_type:'Bank', accountable_id:bank.id, grouping_id: account.grouping_id)
      # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
    end

  def cheque_post
    ref_bank = 'RECEIVABLE'
    bank = Bank.find_by_reference(ref_bank)
    entity = 'Account'
    type = 'sales'
    account = Account.find_by_name(bank.name)
    desc = "#{account.name} debit: #{ref_bank}"
    @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                         postable_id: @daily.id, debit_amount: @daily.cheque, credit_amount: 0, account_id:account.id,
                         accountable_type:'Bank', accountable_id:bank.id, grouping_id: account.grouping_id)

    net =  (@daily.cheque / (1 + CONFIG[:vat_rate_standard])).to_i
    account = Account.find_by_name('Sales Pending')
    desc = "#{account.name} credit: #{ref_bank}"
    @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                         postable_id: @daily.id, debit_amount: 0, credit_amount: net, account_id:account.id,
                         accountable_type:'Bank', accountable_id:bank.id, grouping_id: account.grouping_id)
    tax =  @daily.cheque - net
    account = Account.find_by_name('VAT Pending')
    desc = "#{account.name} credit: #{ref_bank}"
    @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                         postable_id: @daily.id, debit_amount: 0, credit_amount: tax, account_id:account.id,
                         accountable_type:'Bank', accountable_id:bank.id, grouping_id: account.grouping_id)
    # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
  end

  def net_sales_post
    credit = true
    entity = 'Account'
    type = 'sales'
    account = Account.find_by_name('Sales')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}"
    @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                         postable_id: @daily.id, debit_amount: 0, credit_amount: @daily.turnover, account_id:account.id,
                         accountable_type:'Account', accountable_id:account.id, grouping_id: account.grouping_id)
  end

  def vat_post
    ref_bank = 'VAT'
    bank = Bank.find_by_reference(ref_bank)
    credit = true
    entity = 'Account'
    type = 'sales'
    account = Account.find_by_name('VAT Control')
    if account
      entity_id = account.id
      entity_ref = account.code
    end
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{ref_bank}"
    @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                         postable_id: @daily.id, debit_amount: 0, credit_amount: @daily.tax, account_id:account.id,
                         accountable_type:'Bank', accountable_id:bank.id, grouping_id: account.grouping_id)
    # @daily.financials.create!(event_date: @daily.account_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, summary: summary, desc: desc, debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
  end

  def goods_post
    credit = true
    entity = 'Account'
    type = 'sales'
    account = Account.find_by_name('Goods')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}"
    @daily.posts.create( account_date:  @daily.account_date, desc: desc, postable_type: 'Daily',
                         postable_id: @daily.id, debit_amount: 0, credit_amount: @daily.goods, account_id:account.id,
                         accountable_type:'Account', accountable_id:account.id, grouping_id: account.grouping_id)
  end

    def tips_post
      ref_bank = 'TIPS'
      bank = Bank.find_by_reference(ref_bank)
      credit = true
      credit_amount = @daily.tips
      debit_amount = 0
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
                           accountable_type:'Bank', accountable_id:bank.id, grouping_id: account.grouping_id)
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

  def get_orders_summary
    @orders = get_daily_orders
    if @orders.size > 0
      @daily.credit_card_cents = get_credit_card
      @daily.cheque_cents = get_cheque
      @daily.cash_cents = get_cash
      @daily.tips_cents = get_tips
      @daily.goods_cents = get_goods
    end
  end

  def get_credit_card
    @orders.to_a.sum(&:credit_card_cents)
  end

  def get_cheque
    @orders.to_a.sum(&:cheque_cents)
  end

  def get_cash
    @orders.to_a.sum(&:cash_cents)
  end

  def get_goods
     @orders.to_a.sum(&:goods_cents)
  end

  def get_tips
    @orders.to_a.sum(&:tip_cents)
  end

  def get_daily_orders
    Order.where(session: @daily.session, effective_date: @daily.account_date)
  end
    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @daily
  end
end
