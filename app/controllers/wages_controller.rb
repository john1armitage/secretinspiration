class WagesController < ApplicationController
  before_action :set_wage, only: [:show, :edit, :update, :destroy]

  # GET /wages
  def index
    @wages = Wage.limit(5000)
    if params[:this_year].present?
      fy_start = "06-04-#{Date.today.year}".to_date
      fy_start = fy_start - 1.year if fy_start > Date.today
      @fy = fy_start.year
      @wages = @wages.where(fy: @fy)
    elsif params[:fy].present?
      @fy = params[:fy]
      @wages = @wages.where(fy: params[:fy].to_i)
      if params[:week_no].present?
        @week_no = params[:week_no]
        @wages = @wages.where(week_no: params[:week_no].to_i)
      end
    elsif !params[:employee_id].present? && cookies[:last_wage_fy] && cookies[:last_wage_week_no]
      @fy = cookies[:last_wage_fy]
      @week_no = cookies[:last_wage_week_no]
      @wages = Wage.where(fy: @fy, week_no: @week_no)
    end
    if params[:employee_id].present?
      @wages = @wages.where(employee_id: params[:employee_id])
    end

    @wages = @wages.joins(:employee).includes(:posts).select( "wages.*, employees.first_name")
  end

  # GET /wages/1
  def show
  end

  # GET /wages/new
  def new
    if params[:dailies.present?]
      @wage = Wage.where(employee_id: params[:employee_id], fy: params[:fy], week_no: params[:week_no]).first
      @wage = Wage.new(employee_id: params[:employee_id], fy: params[:fy], week_no: params[:week_no]) unless @wage
      @wage.hours = params[:hours]
      @wage.rate_cents = params[:rate]
      @wage.gross_cents = @wage.hours.to_d * @wage.rate_cents.to_d
      @wage.tips_cents = params[:tips]
      @wage.bonus_cents = 0
      @wage.holiday_cents = 0
      @wage.paid_date = params[:pay_day] if @wage.paid_date.blank?
      render 'edit'
    else
      @wage = Wage.new
      @wage.fy = cookies[:last_wage_fy] if cookies[:last_wage_fy]
      @wage.employee_id = cookies[:last_employee] if cookies[:last_employee]
      @wage.rate = cookies[:last_rate] if cookies[:last_rate]
      @wage.week_no = cookies[:last_wage_week_no].to_i + 1 if cookies[:last_wage_week_no]
      @wage.paid_date = cookies[:last_paid_date].to_date + 7.days if cookies[:last_paid_date]
    end
    @wage = check_nil_cents(@wage)
  end

  # GET /wages/1/edit
  def edit
  end

  # POST /wages
  def create
    @wage = Wage.new(params[:wage])

    @wage = check_nil_cents(@wage)

    if @wage.save!
      create_posts(@wage) if @wage.post
      cookies[:last_wage_fy] = @wage.fy
      cookies[:last_employee] = @wage.employee_id
      cookies[:last_rate] = @wage.rate
      cookies[:last_wage_week_no] = @wage.week_no
      cookies[:last_paid_date] = @wage.paid_date
      redirect_to wages_url(fy: @wage.fy, week_no: @wage.week_no), notice: 'Wage was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /wages/1
  def update

    if @wage.update!(params[:wage])
      @wage = check_nil_cents(@wage)
      @wage.save
      # if params[:editor].present?
      remove_posts(@wage)
      create_posts(@wage) if @wage.post
      cookies[:last_wage_fy] = @wage.fy
      cookies[:last_wage_week_no] = @wage.week_no
      cookies[:last_paid_date] = @wage.paid_date
      if params[:timesheets].present?
        redirect_to timesheets_url(week: params[:timesheets]), notice: 'Wage was successfully updated.'
      else
        redirect_to wages_url(week_no: @wage.week_no, fy: @wage.fy), notice: 'Wage was successfully updated.'
      end
      # redirect_to timesheets_url(week: params[:week], no_process: true), notice: 'Wage was successfully updated.'
      # else
      #   redirect_to wages_url(fy: @wage.fy, week_no: @wage.week_no), notice: 'Wage was successfully updated.'
      # end
    else
      render action: 'edit'
    end
  end

  # DELETE /wages/1
  def destroy
    fy = @wage.fy
    week_no = @wage.week_no
    remove_posts(@wage)
    @wage.destroy
    redirect_to wages_url(fy: fy, week_no: week_no), notice: 'Wage was successfully destroyed.'
  end

  private

  def check_nil_cents(wage)
    wage.gross = 0.00 unless wage.gross && wage.gross > 0
    wage.holiday = 0.00 unless wage.holiday && wage.holiday > 0
    wage.bonus = 0.00 unless wage.bonus && wage.bonus > 0
    wage.paye = 0.00 unless wage.paye
    wage.ni_employee = 0.00 unless wage.ni_employee
    wage.ni_employer = 0.00 unless wage.ni_employer
    wage
  end

  def remove_posts(wage)
    wage.posts.destroy_all
  end
  def create_posts(wage)
    weeks = wage.week_no - 1
    @account_date = "#{wage.fy}-04-06".to_date + (weeks * 7).days
    # wages
    wages_post(wage)
    # # tax control
    hmrc_post(wage)
    # holiday control
    holiday_post(wage) if wage.employee.holiday && wage.gross > 0
    # employer costs
    payroll_cost_post(wage)
    # tips control
    tips_post(wage) if wage.tips > 0
  end
  def wages_post(wage)
    credit = true
    credit_amount = wage.gross + wage.holiday + wage.bonus - ( wage.paye + wage.ni_employee )
    if credit_amount > 0
      debit_amount = 0.00
      account = Account.find_by_name('Wages Payable')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{@wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                           postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                           accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
  end
  def tips_post(wage)
    credit = false
    credit_amount = 0.00
    debit_amount = wage.tips
    account = Account.find_by_name('Tips Control')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
    wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)

    credit = true
    credit_amount = wage.tips
    debit_amount = 0.00
    account = Account.find_by_name('Allocated Tips')
    desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
    wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: @wage.employee_id, grouping_id: account.grouping_id)
  end

  def hmrc_post(wage)
    if wage.paye > 0.00
      credit = true
      credit_amount = wage.paye
      debit_amount = 0.00
      account = Account.find_by_name('PAYE Control')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                          postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                          accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    if wage.ni_employee > 0.00
      credit = true
      credit_amount = wage.ni_employee
      debit_amount = 0.00
      account = Account.find_by_name('NI Employee')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                          postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                          accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    if wage.ni_employer > 0.00
      credit = true
      credit_amount = wage.ni_employer
      debit_amount = 0.00
      account = Account.find_by_name('NI Employer')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                          postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
                          accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
  end

  def holiday_post(wage)
    credit = true
    credit_amount = wage.gross * CONFIG[:holiday_rate] / 100
    debit_amount = 0.00
    account = Account.find_by_name('Holiday Pay')
    desc = "#{account.name} credit: #{wage.fy}/#{wage.week_no}"
    wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                        postable_id: wage.id, debit_amount: 0, credit_amount: credit_amount, account_id:account.id,
                        accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
  end

  def payroll_cost_post(wage)
    credit = false
    # credit_amount = 0.00
    # debit_amount = wage.gross + wage.holiday + wage.bonus + holiday_earned + wage.ni_employer
    if wage.gross > 0
      account = Account.find_by_name('Hourly Wages')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: wage.id, debit_amount: wage.gross, credit_amount: 0, account_id:account.id,
                         accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    if wage.bonus > 0
      account = Account.find_by_name('Bonus')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: wage.id, debit_amount: wage.bonus, credit_amount: 0, account_id:account.id,
                         accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    if wage.ni_employer > 0
      account = Account.find_by_name('Employer NI')
      desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: wage.id, debit_amount: wage.ni_employer, credit_amount: 0, account_id:account.id,
                         accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    account = Account.find_by_name('Accrued Holiday')
    holiday_earned = wage.employee.holiday ? wage.gross * CONFIG[:holiday_rate] / 100 : 0
    if holiday_earned > 0
      desc = "#{account.name} debit: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: wage.id, debit_amount: holiday_earned, credit_amount: 0, account_id:account.id,
                         accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    credit = true
    if wage.holiday > 0
      # desc = "#{account.name} credit: #{wage.fy}/#{wage.week_no}"
      # wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
      #                    postable_id: wage.id, debit_amount: 0, credit_amount: wage.holiday, account_id:account.id,
      #                    accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
      account = Account.find_by_name('Holiday Pay')
      desc = "#{account.name} debit: #{wage.fy}/#{wage.week_no}"
      wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
                         postable_id: wage.id, debit_amount: wage.holiday, credit_amount: 0, account_id:account.id,
                         accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    end
    # if debit_amount > 0
    #   account = Account.find_by_name('Payroll Costs')
    #   desc = "#{account.name} #{credit ? 'credit' :'debit'}: #{wage.fy}/#{wage.week_no}"
    #   wage.posts.create( account_date:  @account_date, desc: desc, postable_type: 'Wage',
    #                       postable_id: wage.id, debit_amount: debit_amount, credit_amount: credit_amount, account_id:account.id,
    #                       accountable_type:'Employee', accountable_id: wage.employee_id, grouping_id: account.grouping_id)
    # end
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
