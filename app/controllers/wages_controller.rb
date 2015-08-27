class WagesController < ApplicationController
  before_action :set_wage, only: [:show, :edit, :update, :destroy]

  # GET /wages
  def index
    @wages = Wage.limit(50)
    @wages = @wages.where(FY: params[:fy].to_i, week_no: params[:week_no].to_i) if params[:fy].present? && params[:week_no].present?
  end

  # GET /wages/1
  def show
  end

  # GET /wages/new
  def new
    @wage = Wage.where(employee_id: params[:employee_id], FY: params[:fy], week_no: params[:week_no]).first
    @wage = Wage.new(employee_id: params[:employee_id], FY: params[:fy], week_no: params[:week_no]) unless @wage
    @wage.hours = params[:hours]
    @wage.rate_cents = params[:rate]
    @wage.gross_cents = @wage.hours.to_d * @wage.rate_cents.to_d
    @wage.tips_cents = params[:tips]
    @wage.paid_date = params[:pay_day] if @wage.paid_date.blank?
    render 'edit'
  end

  # GET /wages/1/edit
  def edit
  end

  # POST /wages
  def create
    @wage = Wage.new(params[:wage])

    if @wage.save
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
      redirect_to timesheets_url(week: params[:week], no_process: true), notice: 'Wage was successfully updated.'
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
    credit_amount = @wage.gross - ( @wage.PAYE + @wage.NI_employee )
    debit_amount = 0.00
    account = Account.find_by_name('Wages Payable')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                         accountable_type:'Employee', accountable_id: @wage.employee_id, grouping: account.grouping)
  end
  def tips_post
    credit = false
    credit_amount = 0.00
    debit_amount = @wage.tips
    account = Account.find_by_name('Tips Control')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping: account.grouping)

    credit = true
    credit_amount = @wage.tips
    debit_amount = 0.00
    account = Account.find_by_name('Allocated Tips')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping: account.grouping)
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
                          accountable_type:'Employee', accountable_id: @wage.employee_id, grouping: account.grouping)
    end
    if @wage.NI_employee > 0.00
      credit = true
      credit_amount = @wage.NI_employee
      debit_amount = 0.00
      account = Account.find_by_name('NI Employee')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
      @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                          postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                          accountable_type:'Employee', accountable_id: @wage.employee_id, grouping: account.grouping)
    end
    if @wage.NI_employer > 0.00
      credit = true
      credit_amount = @wage.NI_employer
      debit_amount = 0.00
      account = Account.find_by_name('NI Employer')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
      @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                          postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                          accountable_type:'Employee', accountable_id: @wage.employee_id, grouping: account.grouping)
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
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping: account.grouping)
  end

  def payroll_cost_post
    credit = false
    credit_amount = 0.00
    debit_amount = @wage.gross + ( @wage.gross * CONFIG[:holiday_rate] / 100 ) + @wage.NI_employer
    account = Account.find_by_name('Payroll Costs')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{@wage.FY}/#{@wage.week_no}"
    @wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: @wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping: account.grouping)
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
