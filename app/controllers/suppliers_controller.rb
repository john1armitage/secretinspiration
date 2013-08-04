class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  # GET /suppliers
  def index
    unless params[:term].present?
      @suppliers = Supplier.all
    else
      @suppliers = Supplier.order(:name).where("name ILIKE ?", "%#{params[:term]}%")
      render :json => @suppliers.map{|c| c.name}, root: false
    end
  end

  # GET /suppliers/1
  def show
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new
  end

  # GET /suppliers/1/edit
  def edit
  end

  # POST /suppliers
  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to suppliers_url, notice: 'Supplier was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /suppliers/1
  def update
    if @supplier.update(supplier_params)
      redirect_to suppliers_url, notice: 'Supplier was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /suppliers/1
  def destroy
    @supplier.destroy
    redirect_to suppliers_url, notice: 'Supplier was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def supplier_params
      params.require(:supplier).permit(:name, :phone1, :phone2, :email, :notes, :opening_balance)
    end
end
