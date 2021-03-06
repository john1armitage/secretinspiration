class TimesheetsController < ApplicationController
  before_action :set_timesheet, only: [:show, :edit, :update, :destroy]

  # GET /timesheets
  def index
    if params[:month].present?
      month = params[:month].to_date
      limits = get_work_month(month).split(':')
      start = limits[0]
      stop = limits[1]
      stop = Date.today.strftime('%Y-%m-%d') if stop.to_date > Date.today
      @employee = Employee.find(params[:employee])
      @timesheets = Timesheet.includes(:employee).where( "timesheets.work_date >= ? AND timesheets.work_date <= ? and employee_id = ?", start, stop, params[:employee] ).order('work_date, session DESC') #.select("timesheets.*, dailies.tips_cents as tips, dailies.headcount as headcount")
      @dailies = Daily.where( "account_date >= ? AND account_date <= ?", start, stop ).order('account_date, session DESC').select("tips_cents, headcount") #.select("timesheets.*, dailies.tips_cents as tips, dailies.headcount as headcount")
      @template = 'employee'
    elsif params[:week].present?
      start = params[:week].to_date
      stop = start + 6.days
      stop = Date.today if stop.to_date > Date.today
      @timesheets = Timesheet.includes(:employee).joins('LEFT OUTER JOIN dailies ON dailies.account_date = timesheets.work_date AND dailies.session = timesheets.session').where( "timesheets.work_date >= ? AND timesheets.work_date <= ?", start, stop).order('employee_id, work_date, session DESC')
      @dailies = Daily.where( "account_date >= ? AND account_date <= ?", start, stop ).order('account_date, session DESC').select("tips_cents, headcount")
      @wages = process_timesheets(@timesheets)
      @template = 'payroll'
    else
      @timesheets = Timesheet.order('work_date DESC, session DESC, employee_id')
    end
  end

  # GET /timesheets/1
  def show
  end

  # GET /timesheets/new
  def new
    @timesheet = Timesheet.new
    @timesheet.work_date = params[:date].present? ? params[:date] :  Date.today
    @timesheet.start_time = '18:00'
    @timesheet.end_time = '22:00'
    @timesheet.session = 'dinner'
    render 'form'
  end

  # GET /timesheets/1/edit
  def edit
    render 'form'
  end

  # POST /timesheets
  def create
    calculate_hours(params[:timesheet][:start_time], params[:timesheet][:end_time])
    @timesheet = Timesheet.new(params[:timesheet])

    if @timesheet.save
      redirect_to dailies_url(daily_date: @timesheet.work_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
    else
      render 'form'
    end
  end

  # PATCH/PUT /timesheets/1
  def update
    calculate_hours(params[:timesheet][:start_time], params[:timesheet][:end_time])
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
    def calculate_hours(starting, ending)
      start_time = starting.to_time
      end_time = ending.to_time
      end_time += 1.day if ((end_time.to_time - '00:00'.to_time) < 7200)
      params[:timesheet][:hours] = ( end_time - start_time) / 3600
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_timesheet
      @timesheet = Timesheet.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @timesheet
  end
end
