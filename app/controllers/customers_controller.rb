class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  def index
    unless params[:term].present?
      @customers = Customer.all
    else
      @customers = Customer.order(:name).where("name ILIKE ?", "%#{params[:term]}%")
      render :json => @customers.map{|c| c.name}, root: false
    end
  end

  # GET /customers/1
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  def create
    @customer = Customer.new(params[:customer])

    if @customer.save
      redirect_to @customer, notice: 'Customer was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(params[:customer])
      redirect_to @customer, notice: 'Customer was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /customers/1
  def destroy
    @customer.destroy
    redirect_to customers_url, notice: 'Customer was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

  def current_resource
    @current_resource ||= @customer
  end
end
