class DailiesController < ApplicationController
  before_action :set_daily, only: [:show, :edit, :form, :update, :destroy]

  # GET /dailies
  def index
    #@dailies = Daily.all
    set_daily_dates
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
    render 'form'
  end

  def edit
    @daily.headcount = get_headcount
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
    if @daily.save
      redirect_to dailies_url, notice: 'Daily was successfully created.'
    else
      render action: 'form'
    end
  end

  # PATCH/PUT /dailies/1
  def update
    if @daily.update(params[:daily])
      redirect_to dailies_url, notice: 'Daily was successfully updated.'
    else
      render action: 'form'
    end
  end

  # DELETE /dailies/1
  def destroy
    @daily.destroy
    set_daily_dates
    render 'index'
#    redirect_to dailies_url, notice: 'Daily was successfully destroyed.'
  end

  private
  # def set_daily_dates
  #   @daily_date = @daily.account_date if @daily
  #   @daily_date ||= params['daily_date'].present? ? params['daily_date'].to_date : Date.today
  #   # @dailies = Daily.where( account_date: @daily_date ).order(:arrival, :customer_name)
  #   #@requests = Booking.where( 'confirmed = ?', false ).order(:booking_date, :customer_name)
  #   @dailies_by_date = get_dailies(@daily_date)
  #   @dailies_last_month = get_dailies(@daily_date - 1.month)
  #   @timesheets_by_date = get_timesheets(@daily_date)
  #   @timesheets_last_month = get_timesheets(@daily_date - 1.month)
  # end
  # #helper_method :set_daily_dates
  #
  # def get_dailies(daily_date)
  #   start = (daily_date <= Time.now.at_beginning_of_day) ? Time.now.to_date : daily_date.beginning_of_month
  #   stop = daily_date.end_of_month
  #   Daily.where('account_date >= ? AND account_date <= ?', start, stop ).group_by(&:account_date)
  # end
  #
  # def get_timesheets(daily_date)
  #   start = (daily_date <= Time.now.at_beginning_of_day) ? Time.now.to_date : daily_date.beginning_of_month
  #   stop = daily_date.end_of_month
  #   Timesheet.where('work_date >= ? AND work_date <= ?', start, stop ).group_by(&:work_date)
  # end
  #
  #
  # def get_headcount
  #     Timesheet.where('work_date = ? AND session = ?', @daily.account_date, @daily.session).size
  #   end
    # Use callbacks to share common setup or constraints between actions.
    def set_daily
      @daily = Daily.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @daily
  end
end
