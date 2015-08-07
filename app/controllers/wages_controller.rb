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
    # Use callbacks to share common setup or constraints between actions.
    def set_wage
      @wage = Wage.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @wage
  end
end
