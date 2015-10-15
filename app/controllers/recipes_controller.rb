class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  # GET /recipes.json
  def index

    if params[:item_id].present?
      @item = Item.find(params[:item_id])
      @recipes = @item.recipes
    else
      @recipes = Recipe.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recipes }
    end
  end

  # GET /recipes/1
  # GET /recipes/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recipe }
    end
  end

  # GET /recipes/new
  def new
    if params[:item_id].present?
      @item = Item.find(params[:item_id])
      @recipe = @item.recipes.new(params[:recipe])
    else
      @recipe = Recipe.new(params[:recipe])
    end
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes

  # POST /recipes.json
  def create
    @recipe = Recipe.new(params[:recipe])

    respond_to do |format|
      if @recipe.save
        format.html { redirect_to recipes_url(item_id: @recipe.item_id) }
        format.json { render json: @recipe, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1
  # PATCH/PUT /recipes/1.json
  def update
    respond_to do |format|
      if @recipe.update(params[:recipe])
        format.html { redirect_to recipes_url(item_id: @recipe.item_id) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.json
  def destroy
    @item_id = @recipe.item_id
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_to recipes_url(item_id: @item_id) }
      format.json { head :no_content }
    end
  end

  def quantities
    unit_id = Ingredient.find(params[:ingredient_id]).unit_id
    @quantities = get_quantities(unit_id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

      # Only allow a trusted parameter "white list" through.
    def current_resource
      @current_resource ||= @recipe
    end

end
