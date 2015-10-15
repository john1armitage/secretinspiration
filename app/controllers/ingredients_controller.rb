class IngredientsController < ApplicationController
  before_action :set_ingredient, only: [:show, :edit, :update, :destroy]
  before_action :get_suppliers, only: [:index, :new, :edit, :create, :update]

  # GET /ingredients
  # GET /ingredients.json
  def index

    @q = Ingredient.search(params[:q])

    @ingredients =  @q.result(distinct: true).order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ingredients }
    end
  end

  # GET /ingredients/1
  # GET /ingredients/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ingredient }
    end
  end

  # GET /ingredients/new
  def new
    @ingredient = Ingredient.new
    @ingredient.unit_id = Element.find_by_name('ml').id
  end

  # GET /ingredients/1/edit
  def edit
    # @ingredient = Ingredient.find(params[:id])
  end

  # POST /ingredients
  # POST /ingredients.json
  def create
    @ingredient = Ingredient.new(params[:ingredient])

    respond_to do |format|
      if @ingredient.save
        format.html { redirect_to ingredients_url(supplier_id: @ingredient.supplier_id) }
        format.json { render json: @ingredient, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ingredients/1
  # PATCH/PUT /ingredients/1.json
  def update
    # @ingredient = Ingredient.find(params[:id])
    respond_to do |format|
      if @ingredient.update(params[:ingredient])
        format.html { redirect_to ingredients_url(supplier_id: @ingredient.supplier_id) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ingredients/1
  # DELETE /ingredients/1.json
  def destroy
    @supplier_id = @ingredient.supplier_id
    @ingredient.destroy
    respond_to do |format|
      format.html { redirect_to ingredients_url(supplier_id: @supplier_id) }
      format.json { head :no_content }
    end
  end

  def quantities
    @quantities = get_quantities(params[:unit_id])
  end

  private

    def get_suppliers
      @suppliers = Supplier.where(ordering: true).order(:name)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_ingredient
      @ingredient = Ingredient.find(params[:id])
    end

      # Only allow a trusted parameter "white list" through.
    def current_resource
      @current_resource ||= @ingredient
    end

end
