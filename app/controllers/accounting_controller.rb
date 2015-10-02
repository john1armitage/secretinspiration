class AccountingController < ApplicationController
  def index
    @periods = Element.where(kind: 'financial').order(:rank)
    if params[:period].present?
      @period =  params[:period]
    # elsif !params[:account_date_gteq] && !params[:account_date_lteq]
    #   @period = 'FY to date'

      case @period
        when 'FY to date'
          period = fy_to_date
          params[:account_date_gteq] = period[0]
          params[:account_date_lteq] = period[1]
        when 'FQ to date'
          period = fq_to_date
          params[:account_date_gteq] = period[0]
          params[:account_date_lteq] = period[1]
        when 'Last FY'
          period = last_fy
          params[:account_date_gteq] = period[0]
          params[:account_date_lteq] = period[1]
        when 'Last FQ'
          period = last_fq
          params[:account_date_gteq] = period[0]
          params[:account_date_lteq] = period[1]
        else
          params[:account_date_gteq] = ''
          params[:account_date_lteq] = ''
      end
    end
    @start = params[:account_date_gteq] ?  params[:account_date_gteq] : '2001-01-01'.to_date
    @stop = params[:account_date_lteq] ? params[:account_date_lteq] : Date.today
    @stop = nil if @start && @stop && @start > @stop

    goodwill = Account.find_by_name('Goodwill')

    previous_posts = Post.includes(:account).joins('JOIN accounts AS groupings ON groupings.id = posts.grouping_id').where('account_date < ?',@start)
    previous_posts = previous_posts.where('groupings.name = ? AND debit_amount_cents > 0','Fixed Assets')
    previous_depreciations = Depreciation.includes(financial: :account).where('service_date < ?',@start)
    @fixed_assets_previous = previous_posts.sum('debit_amount_cents').to_d / 100
    @intangibles_previous = previous_posts.where('posts.account_id = ?',goodwill).sum('debit_amount_cents').to_d / 100
    @tangibles_previous = @fixed_assets_previous - @intangibles_previous
    @depreciation_previous = previous_depreciations.where('financials.account_id = ?',goodwill).sum('allowable_cost_cents').to_d / 100
    @intangible_depreciation_previous = previous_depreciations.sum('allowable_cost_cents').to_d / 100
    @tangible_depreciation_previous = @depreciation_previous - @intangible_depreciation_previous
    depreciations = Depreciation.where('service_date >= ? AND service_date <= ? ',@start, (@stop || Time.now))
    depreciations = depreciations.includes(financial: :account)

    amortisations = depreciations.where('name = ?', 'Goodwill')
    depreciations = depreciations.where('name <> ?', 'Goodwill')

    @amortisation = amortisations.sum('allowable_cost_cents').to_d / 100
    @depreciation = depreciations.sum('allowable_cost_cents').to_d / 100

    posts = Post.joins('JOIN accounts AS groupings ON groupings.id = posts.grouping_id').where('account_date >= ?',@start)
    posts = posts.where('account_date <= ?',@stop) if @stop

    @direct_costs = posts.where('groupings.name = ? AND debit_amount_cents > 0','Direct Costs').sum('debit_amount_cents').to_d / 100
    overheads = posts.where('groupings.name = ? AND debit_amount_cents > 0','Overheads')
    @overheads = overheads.sum('debit_amount_cents').to_d / 100
    @disallowed = posts.where('groupings.name = ? AND debit_amount_cents > 0','Disallowed').sum('debit_amount_cents').to_d / 100
    @fixed_assets = posts.where('groupings.name = ? AND debit_amount_cents > 0','Fixed Assets').sum('debit_amount_cents').to_d / 100

    @intangibles = posts.where('posts.account_id = ?',goodwill).sum('debit_amount_cents').to_d / 100
    @tangibles = @fixed_assets - @intangibles

    posts = Post.includes(:account).where('account_date >= ?',@start)
    posts = posts.where('account_date <= ?',@stop) if @stop

    cogs = posts.where('accounts.name = ? AND debit_amount_cents > 0','Victual Costs')
    @cogs = cogs.sum('debit_amount_cents').to_d / 100

    # @payroll_costs = posts.where('accounts.name = ? AND debit_amount_cents > 0','Hourly Wages').sum('debit_amount_cents').to_d / 100
    # @payroll_costs += posts.where('accounts.name = ? AND debit_amount_cents > 0','Bonus').sum('debit_amount_cents').to_d / 100
    # @payroll_costs += posts.where('accounts.name = ? AND debit_amount_cents > 0','Employer NI').sum('debit_amount_cents').to_d / 100
    # @payroll_costs += posts.where('accounts.name = ? AND debit_amount_cents > 0','Accrued Holiday').sum('debit_amount_cents').to_d / 100
    # #TEMP historical
    # @payroll_costs += posts.where('accounts.name = ? AND debit_amount_cents > 0','Payroll Costs').sum('debit_amount_cents').to_d / 100

    payroll = posts.where("accounts.name = ANY('{Payroll Costs,Hourly Wages,Bonus,Employer NI,Accrued Holiday}'::text[]) AND debit_amount_cents > 0")
    @payroll_costs = payroll.sum('debit_amount_cents').to_d / 100

    # @grouped_payroll_costs = payroll.joins('INNER JOIN wages ON posts.postable_id = wages.id') #.select('wages.employee_id, sum(debit_amount_cents) as total_cost').group('employee_id')
    # p @grouped_payroll_costs

    @sales = posts.where('accounts.name = ? AND credit_amount_cents > 0','Sales').sum('credit_amount_cents').to_d / 100
    @sales_pending = posts.where('accounts.name = ? AND credit_amount_cents > 0','Sales Pending').sum('credit_amount_cents').to_d / 100
    @interest = posts.where('accounts.name = ? AND credit_amount_cents > 0','Bank Interest').sum('credit_amount_cents').to_d / 100
    @vat_paid = posts.where('accounts.name = ? AND debit_amount_cents > 0','VAT Control').sum('debit_amount_cents').to_d / 100
    # @vat_received = posts.where('accounts.name = ? AND credit_amount_cents > 0','VAT Control').sum('credit_amount_cents').to_d / 100
    @vat_received = @sales * CONFIG[:vat_rate_standard]

    @grouped_overheads = overheads.joins(:account).order('accounts.code').select('accounts.code, accounts.name, sum(debit_amount_cents) as total_cost').group('accounts.code, accounts.name') #.having("sum(price) > ?", 100)

    prepayments = Financial.where(annual: true)
    @prepayments = 0

    prepayments.each do |prepayment|
      date = prepayment.effective_date || prepayment.event_date
      elapsed = (@stop.to_date - date).to_i
      if elapsed > 0 && elapsed < 365
        remaining = (365 - elapsed)
        amount = ( prepayment.credit_amount_cents * remaining / 365 )
        @prepayments += amount
      end
    end
    @prepayments = (@prepayments / 100).to_i
  end
end

