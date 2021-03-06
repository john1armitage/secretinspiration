class VariantsController < ApplicationController
  before_action :set_variant, only: [:show, :edit, :update, :destroy]
  #before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_item_param, only: [:new]
#  before_action :set_state, only: [:carts, :update]

  # GET /variants
  def index

    unless params[:term].present?
      set_item_param if params[:item_id].present?
      @variants = @item ? @item.variants : Variant.all
      @variants = @variants.order(:name).where( :domain => current_tenant.domain)
    else
      if params[:supplier_id].present?
        @variants = Variant.includes( :item => :supplies ).order(:name).where("(variants.name ILIKE ? or items.name ILIKE ?) and product_flow <> ? and supplies.supplier_id = ?", "%#{params[:term]}%", "%#{params[:term]}%", 'outgoing', params[:supplier_id]).references(:items)
      else
        @variants = Variant.includes(:item).order(:name).where("(variants.name ILIKE ? or items.name ILIKE ?) and product_flow <> ?", "%#{params[:term]}%", "%#{params[:term]}%", 'outgoing').references(:items)
      end

      render :json => @variants.map{|c| (c.name == 'default' ? c.item.name : c.name )}.uniq, root: false
    end
  end


  # GET /variants/1
  def show
    read_arrays
    @pics = @variant.pics
  end

  # GET /variants/new
  def new
    @variant = @item.variants.new
  end

  # GET /variants/1/edit
  def edit
    read_arrays
  end

  # POST /variants
  def create
    store_arrays
    @variant = Variant.new(params[:variant])
    @variant.domain = current_tenant.domain
    set_item
    if @variant.save
      remove_defaults(@variant.id) if @variant.item_default
      redirect_to variants_url(:item_id => @item.id), notice: 'Variant was successfully created.'
    else
      @item = @variant.item
      render action: 'new'
    end
  end

  # PATCH/PUT /variants/1
  def update
    store_arrays
    if @variant.update(params[:variant])
      if @variant.item_default
        remove_defaults(@variant.id)
      else
        unless default_exists
          @variant.update_column(item_default, true) unless force_default(@variant.id)
        end
      end
      redirect_to variants_url(:item_id => @item.id), notice: 'Variant was successfully updated.'
    else
      read_arrays
      render action: 'edit'
    end
  end

  # DELETE /variants/1
  def destroy
    set_item
    @variant.destroy
    unless default_exists
      @item.variants.create(name: 'default', domain: current_tenant.domain, item_default: true, withdrawn: false) unless force_default
    end
   # @item.variants.create(name: 'default', domain: current_tenant.domain, item_default: true) if @item.variants.size == 0
    redirect_to variants_url(:item_id => @item.id), notice: 'Variant was successfully destroyed.'
  end

  private
  def default_exists
    @item.variants.where(item_default: true).size > 0
  end

  def force_default(id = -999)
    candidates = get_candidates(id)
    if candidates.size > 0
       candidates.first.update_columns(item_default: true)
      true
    else
      false
    end
  end

  def remove_defaults(id)
    if candidates = get_candidates(id)
      candidates.each do |c|
        c.update_columns( item_default: false)
      end
    end
  end

  def get_candidates(id)
    @item.variants.where(domain: current_tenant.domain).where.not( id: id )
  end
  def get_item_type_properties
    @properties = @variant.item_type.properties
  end

  def read_arrays
    get_collections
    @collections.each do |field|
      eval( "@#{field.name} = @variant.#{field.name}.split('-') if @variant.#{field.name}" )
    end
  end

  def store_arrays
    get_collections
    @collections.each do |field|
      selected = []
      if params[ field.name ].present?
        params[field.name].each do |k,v|
        # params[:sizes].each do |k,v|
          selected << k
        end
      end
      eval( "params[:variant][:#{field.name}] = selected.join('-')" )
    end
  end

  def read_sizes
    @sizes = @variant.sizes.split('-')
  end

  def store_sizes
    sizes = []
    params[:sizes].each do |k,v|
      sizes << k
    end
    params[:variant][:sizes] = sizes.join("-")
  end
    # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = @variant.item
  end

  def set_item_param
    @item = Item.find(params[:item_id])
  end

  def set_variant
    @variant = Variant.find_by_slug(params[:id])
    set_item
  end

  def current_resource
    @current_resource ||= Variant.find_by_slug(params[:id])  if params[:id]
  end

end
