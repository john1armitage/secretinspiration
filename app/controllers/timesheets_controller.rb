class TimesheetsController < ApplicationController
  before_action :set_timesheet, only: [:show, :edit, :update, :destroy]

  # GET /timesheets
  def index
    month = params[:month].to_date
    start = month.beginning_of_month
    finish = month.end_of_month
    @employee = Employee.find(params[:employee])
    @timesheets = Timesheet.includes(:employee).joins('LEFT OUTER JOIN dailies ON dailies.account_date = timesheets.work_date AND dailies.session = timesheets.session').where( "timesheets.work_date >= ? AND timesheets.work_date <= ? and employee_id = ?", start, finish, params[:employee] ).order('work_date, session DESC').select("timesheets.*, dailies.tips_cents as tips, dailies.headcount as headcount")
  end

  # GET /timesheets/1
  def show
  end

  # GET /timesheets/new
  def new
    @timesheet = Timesheet.new
    @timesheet.work_date = params[:date].present? ? params[:date] :  Date.today
    @timesheet.start_time = @timesheet.end_time = Time.now
    @timesheet.session = 'dinner'
    render 'form'
  end

  # GET /timesheets/1/edit
  def edit
    render 'form'
  end

  # POST /timesheets
  def create
    @timesheet = Timesheet.new(params[:timesheet])

    if @timesheet.save
      redirect_to dailies_url(daily_date: @timesheet.work_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
    else
      render 'form'
    end
  end

  # PATCH/PUT /timesheets/1
  def update
    if @timesheet.update(params[:timesheet])
      redirect_to dailies_url(daily_date: @timesheet.work_date.strftime('%d-%m-%Y')), notice: 'Timesheet was successfully updated.'
    else
      render 'form'
    end
  end

  # DELETE /timesheets/1
  def destroy
    params[:daily_date] = @timesheet.work_date.strftime('%d-%m-%Y')

    @timesheet.destroy
    set_daily_dates
    render 'dailies/index'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_timesheet
      @timesheet = Timesheet.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @timesheet
  end
end
