class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  def index
    get_root_categories
    @items = Item.order(:item_type_id, :category_id, :name).all
  end

  # GET /items/1
  def show
  end

  # GET /items/new
  def new
    @item = Item.new
    p params[:root_category]
    @categories = get_categories( params[:root_category])
    p @categories
  end

  # GET /items/1/edit
  def edit
    p @item.category.root.name
    @categories = get_categories( @item.category.root.name )
    p @categories
  end

  # POST /items
  def create
    @item = Item.new(params[:item].merge(domain: current_tenant.domain, vat_exempt: current_tenant.vat_exempt))
    if @item.save
      redirect_to items_url, notice: 'Item was successfully created.'
    else
      get_categories(params[:item][:item_type_id])
      render action: 'new'
    end
  end

  # PATCH/PUT /items/1
  def update
    if @item.update(params[:item].merge(:domain => current_tenant.domain))
      redirect_to items_url, notice: 'Item was successfully updated.'
    else
      get_categories(@item.category.root.name)
      render action: 'edit'
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy
    redirect_to items_url, notice: 'Item was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find_by_slug( params[:id] )
        #   @item = Item.find(params[:id])  .find_by_slug(params[:id])
    end

  def get_root_categories  #  "data -> 'foo' = :value", value: true)
    @root_categories = Category.where( :ancestry_depth => 0 )
  end
    ## Only allow a trusted parameter "white list" through.
    #def item_params
    #  params.require(:item).permit(:name)
    #end

  #def get_categories( item_type_id )
  #  item_type =  ItemType.find( item_type_id )
  #  category = Category.find_by_name( item_type.name )
  #  if category
  #    root_id = category.id
  #    @categories = Category.at_depth( item_type.menu_depth - 1 ).where(:root_id => root_id ).order(:rank).load
  #  else
  #    @categories = []
  #  end
  #end
  #
  def current_resource
    @current_resource ||= @item
  end

end
