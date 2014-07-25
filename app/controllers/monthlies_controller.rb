class MonthliesController < ApplicationController
  before_action :set_monthly, only: [:show, :edit, :update, :destroy]

  # GET /monthlies
  def index
    @monthlies = Monthly.all
  end

  # GET /monthlies/1
  def show
  end

  # GET /monthlies/new
  def new
    @monthly = Monthly.new
  end

  # GET /monthlies/1/edit
  def edit
  end

  # POST /monthlies
  def create
    @monthly = Monthly.new(params[:monthly])

    if @monthly.save
      redirect_to monthlies_url, notice: 'Monthly was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /monthlies/1
  def update
    if @monthly.update(params[:monthly])
      redirect_to monthlies_url, notice: 'Monthly was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /monthlies/1
  def destroy
    @monthly.destroy
    redirect_to monthlies_url, notice: 'Monthly was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_monthly
      @monthly = Monthly.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def monthly_params
      @current_resource ||= @month
    end
end
