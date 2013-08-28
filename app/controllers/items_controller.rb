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
    if params[:category_id]
      category = Category.find(params[:category_id])
      params[:category_root] = category.root
      @item.category_id = category.id
      @item.product_flow = category.parent.product_flow
      @item.vat_rate = category.parent.vat_rate
    end
  end

  # GET /items/1/edit
  def edit
    #@categories = get_categories( @item.category.root.name )
  end

  # POST /items
  def create
    sups = params[:item][:sups]
    params[:item].delete :sups
    @item = Item.new(params[:item].merge(domain: current_tenant.domain, vat_exempt: current_tenant.vat_exempt))
    if @item.save
      set_sups(sups)
      redirect_to items_url, notice: 'Item was successfully created.'
    else
      get_categories(params[:item][:item_type_id])
      render action: 'new'
    end
  end

  # PATCH/PUT /items/1
  def update
    sups = params[:item][:sups]
    params[:item].delete :sups
    set_sups(sups)
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

  def current_resource
    @current_resource ||= @item
  end

  def set_sups(sups)
    @item.supplies.each do |old|
      old.destroy unless sups.include?( old.supplier_id )
    end

    supset = @item.supplies.map {|o| o.supplier_id}
    p "SUPS"
    p sups
    sups.each do |sup|
      @item.supplies.create(supplier_id: sup) unless ( sup.blank? or supset.include?(sup))
    end
  end


end
