class DailiesController < ApplicationController
  before_action :set_daily, only: [:show, :edit, :form, :update, :destroy]

  # GET /dailies
  def index
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
    set_net
    if @daily.save
      redirect_to dailies_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
      # redirect_to daily_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
    else
      render action: 'form'
    end
  end

  # PATCH/PUT /dailies/1
  def update
    set_net
    if @daily.update(params[:daily])
      redirect_to dailies_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully created.'
      # redirect_to daily_url(daily_date: @daily.account_date.strftime('%d-%m-%Y')), notice: 'Daily was successfully updated.'
    else
      render action: 'form'
    end
  end

  # DELETE /dailies/1
  def destroy
    params[:daily_date] = @daily.account_date.strftime('%d-%m-%Y')
    @daily.destroy
    set_daily_dates
    render 'index'
#    redirect_to dailies_url, notice: 'Daily was successfully destroyed.'
  end

  private
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

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @daily
  end
end
