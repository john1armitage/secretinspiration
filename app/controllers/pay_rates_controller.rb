class PayRatesController < ApplicationController
  before_action :set_pay_rate, only: [:show, :edit, :update, :destroy]

  # GET /pay_rates
  def index
    @pay_rates = PayRate.all
  end

  # GET /pay_rates/1
  def show
  end

  # GET /pay_rates/new
  def new
    @pay_rate = PayRate.new
    @pay_rate.effective_date = '2012-10-01'
  end

  # GET /pay_rates/1/edit
  def edit
  end

  # POST /pay_rates
  def create
    @pay_rate = PayRate.new(params[:pay_rate])

    if @pay_rate.save
      redirect_to pay_rates_url, notice: 'Pay rate was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /pay_rates/1
  def update
    if @pay_rate.update(params[:pay_rate])
      redirect_to pay_rates_url, notice: 'Pay rate was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /pay_rates/1
  def destroy
    @pay_rate.destroy
    redirect_to pay_rates_url, notice: 'Pay rate was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pay_rate
      @pay_rate = PayRate.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @pay_rate
  end
end
