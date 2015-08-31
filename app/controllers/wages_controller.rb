class WagesController < ApplicationController
  before_action :set_wage, only: [:show, :edit, :update, :destroy]

  # GET /wages
  def index
    @wages = Wage.limit(50)
    if params[:fy].present?
      @fy = params[:fy]
      @wages = @wages.where(FY: params[:fy].to_i)
      if params[:week_no].present?
        @week_no = params[:week_no]
        @wages = @wages.where(week_no: params[:week_no].to_i)
      end
    elsif cookies[:last_wage_fy] && cookies[:last_wage_week_no]
      @fy = cookies[:last_wage_fy]
      @week_no = cookies[:last_wage_week_no]
      @wages = Wage.where(FY: @fy, week_no: @week_no)
    end
  end

  # GET /wages/1
  def show
  end

  # GET /wages/new
  def new
    if params[:dailies.present?]
      @wage = Wage.where(employee_id: params[:employee_id], FY: params[:fy], week_no: params[:week_no]).first
      @wage = Wage.new(employee_id: params[:employee_id], FY: params[:fy], week_no: params[:week_no]) unless @wage
      @wage.hours = params[:hours]
      @wage.rate_cents = params[:rate]
      @wage.gross_cents = @wage.hours.to_d * @wage.rate_cents.to_d
      @wage.tips_cents = params[:tips]
      @wage.paid_date = params[:pay_day] if @wage.paid_date.blank?
      render 'edit'
    else
      @wage = Wage.new
      @wage.FY = cookies[:last_wage_fy]
      @wage.week_no = cookies[:last_wage_week_no]
    end
  end

  # GET /wages/1/edit
  def edit
  end

  # POST /wages
  def create
    @wage = Wage.new(params[:wage])

    if @wage.save
      cookies[:last_wage_fy] = @wage.FY
      cookies[:last_wage_week_no] = @wage.week_no
      redirect_to wages_url(fy: @wage.FY, week_no: @wage.week_no), notice: 'Wage was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /wages/1
  def update
    if @wage.update(params[:wage])
      # if params[:editor].present?
      remove_posts
      create_posts
      cookies[:last_wage_fy] = @wage.FY
      cookies[:last_wage_week_no] = @wage.week_no
      redirect_to wages_url(week_no: params[@wage.week_no], fy: @wage.FY), notice: 'Wage was successfully updated.'
      # redirect_to timesheets_url(week: params[:week], no_process: true), notice: 'Wage was successfully updated.'
      # else
      #   redirect_to wages_url(fy: @wage.FY, week_no: @wage.week_no), notice: 'Wage was successfully updated.'
      # end
    else
      render action: 'edit'
    end
  end

  # DELETE /wages/1
  def destroy
    fy = @wage.FY
    week_no = @wage.week_no
    @wage.destroy
    redirect_to wages_url(fy: fy, week_no: week_no), notice: 'Wage was successfully destroyed.'
  end

  private
  def remove_posts
    @wage.posts.destroy_all
  end
  def create_posts
    weeks = @wage.week_no - 1
    @account_date = "#{@wage.FY}-04-06".to_date + (weeks * 7).days
    # wages
    wages_post
    # # tax control
    hmrc_post
    # holiday control
    holiday_post if @wage.employee.holiday
    # employer costs
    payroll_cost_post
    # tips control
    tips_post if @wage.tips > 0
  end
  def wages_post
    credit = true
    credit_amount = @wage.gross + @wage.holiday + @wage.bonus - ( @wage.PAYE + @wage.NI_employee )
    debit_amount = 0.00
    account = Account.find_by_name('Wages Payable')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                         accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)
  end
  def tips_post
    credit = false
    credit_amount = 0.00
    debit_amount = @wage.tips
    account = Account.find_by_name('Tips Control')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)

    credit = true
    credit_amount = @wage.tips
    debit_amount = 0.00
    account = Account.find_by_name('Allocated Tips')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)
  end

  def hmrc_post
    if @wage.PAYE > 0.00
      credit = true
      credit_amount = @wage.PAYE
      debit_amount = 0.00
      account = Account.find_by_name('PAYE')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
      @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                          postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                          accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)
    end
    if @wage.NI_employee > 0.00
      credit = true
      credit_amount = @wage.NI_employee
      debit_amount = 0.00
      account = Account.find_by_name('NI Employee')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
      @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                          postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                          accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)
    end
    if @wage.NI_employer > 0.00
      credit = true
      credit_amount = @wage.NI_employer
      debit_amount = 0.00
      account = Account.find_by_name('NI Employer')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
      @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                          postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                          accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)
    end
  end

  def holiday_post
    credit = true
    credit_amount = @wage.gross * CONFIG[:holiday_rate] / 100
    debit_amount = 0.00
    account = Account.find_by_name('Holiday Pay')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)
  end

  def payroll_cost_post
    credit = false
    credit_amount = 0.00
    debit_amount = @wage.gross + ( @wage.gross * CONFIG[:holiday_rate] / 100 ) + @wage.NI_employer
    account = Account.find_by_name('Payroll Costs')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)
  end

    # Use callbacks to share common setup or constraints between actions.
  def set_wage
    @wage = Wage.find(params[:id])
  end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @wage
  end
end
