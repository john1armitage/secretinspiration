class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :edit, :update, :destroy, :pay]

  # GET /suppliers
  def index
    unless params[:term].present?
      @suppliers = Supplier.all
    else
      @suppliers = Supplier.order(:name).where("name ILIKE ? and name <> ?", "%#{params[:term]}%", current_tenant.home_supplier )
      @suppliers = @suppliers.where("opening_balance_currency = ?", params[:currency] ) if  params[:currency].present?
      render :json => @suppliers.map{|c| c.name}, root: false
    end
  end

  # GET /suppliers/1
  def show
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new
    @supplier.opening_balance_currency = current_tenant.home_currency
  end

  # GET /suppliers/1/edit
  def edit
  end

  # POST /suppliers
  def create
    if params[:entity].present?
      entity
    else
      cats = params[:supplier][:cats]
      params[:supplier].delete :cats
      @supplier = Supplier.new(params[:supplier])
      split_reference
      if @supplier.save
        set_cats(cats)
        redirect_to suppliers_url, notice: 'Supplier was successfully created.'
      else
        render action: 'new'
      end
    end
  end

  def entity
    if params[:supplier][:id].blank?
      @supplier = Supplier.new
      @supplier.name = params[:supplier][:name]
      @supplier.reference << params[:supplier][:reference]
      @supplier.save
    else
      @supplier = Supplier.find(params[:supplier][:id])
      @supplier.reference << params[:supplier][:reference]
      @supplier.save
    end
    redirect_to entity_financials_url
  end

  # PATCH/PUT /suppliers/1
  def update
    cats = params[:supplier][:cats]
    params[:supplier].delete :cats
    set_cats(cats)
    split_reference
    if @supplier.update(params[:supplier])
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

  def split_reference
    params[:supplier][:reference] = params[:supplier][:reference].upcase.split(' ')
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @supplier
  end

  def set_cats(cats)
    @supplier.offerings.each do |old|
      old.destroy unless cats.include?( old.category_id )
    end

    catset = @supplier.offerings.map {|o| o.category_id}
    cats.each do |cat|
      @supplier.offerings.create(category_id: cat) unless ( cat.blank? or catset.include?(cat))
    end
  end

end
