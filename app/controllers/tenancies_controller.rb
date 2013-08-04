class TenanciesController < ApplicationController
  before_action :set_tenancy, only: [:show, :edit, :update, :destroy]

  # GET /tenancies
  def index
    @tenancies = Tenancy.order(:name).all
  end

  # GET /tenancies/1
  def show
  end

  # GET /tenancies/new
  def new
    @tenancy = Tenancy.new
  end

  # GET /tenancies/1/edit
  def edit
  end

  # POST /tenancies
  def create
    @tenancy = Tenancy.new(tenancy_params)

    if @tenancy.save
      redirect_to tenancies_url, notice: 'Tenancy was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /tenancies/1
  def update
    if @tenancy.update(tenancy_params)
      redirect_to tenancies_url, notice: 'Tenancy was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /tenancies/1
  def destroy
    @tenancy.destroy
    redirect_to tenancies_url, notice: 'Tenancy was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenancy
      @tenancy = Tenancy.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tenancy_params
      params[:tenancy]
    end
end
