class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  def index

    get_root_categories

    @groupings = Item.where(stock_item: true).select("grouping, initcap(regexp_replace(regexp_replace(grouping, '^.*:', ''), '_', ' ', 'g')) as title" ).order(:grouping).uniq

    @q = Item.search(params[:q])

    @q.grouping_eq = params[:grouping] if  params[:grouping].present?
    @q.name_cont = params[:name] if  params[:name].present?

    # @items = Item.order(:item_type_id, :category_id, :rank, :name)
    @items = @q.result(distinct: true).order(:item_type_id, :category_id, :rank, :name)

    # @items = @items.where(grouping: params[:grouping]) if params[:grouping].present?


    if params[:stock].present?
      @items = @items.includes(:stocks).where(stock_item: true)
      unless params[:q].present? && params[:q][:grouping_eq].present?
        category = Category.find_by_name('main')
        grouping = "#{category.rank}:#{category.name}"
        @q.grouping_eq = grouping
        @items = @items.where('grouping = ?', grouping)
      end
      if params[:item_id].present?
        @item = Item.find(params[:item_id])
        # @option = params[:item_option]
        # @stocks = @item.stocks.order('stock_date DESC')
      end

      @item_option = params[:option] if params[:option].present?

      render 'stock'
    end
  end

  # GET /items/1
  def show
  end

  # GET /items/new
  def new
    @item = Item.new
    get_stock_bases
    if params[:category_id].present?
      category = Category.find(params[:category_id])
      params[:category_root] = category.root
      @item.category_id = category.id
      @item.product_flow = category.parent.product_flow
      @item.vat_rate = category.parent.vat_rate
    elsif params[:category_root].present?
      @product_flow = Category.find_by_name(params[:category_root]).product_flow
    end
    if current_tenant.vat_exempt
      @item.vat_rate = 'zero'
    else
      @item.vat_rate = category.parent.vat_rate
    end
  end

  # GET /items/1/edit
  def edit
    get_stock_bases
  end

  # POST /items
  def create
    sups = params[:item][:sups]
    params[:item].delete :sups
    @item = Item.new(params[:item].merge(domain: current_tenant.domain, vat_exempt: current_tenant.vat_exempt))
    if @item.save
      set_sups(sups)
      redirect_to choice_url( @item.item_type.name ), notice: 'Item was successfully created.'
      #redirect_to choices_url, notice: 'Item was successfully created.'
    else
      get_categories(params[:item][:item_type_id])
      render action: 'new'
    end
  end

  # PATCH/PUT /items/1
  def update
    if params[:item][:sups].present?
      sups = params[:item][:sups]
      params[:item].delete :sups
      set_sups(sups)
      if @item.update(params[:item].merge(:domain => current_tenant.domain))
        redirect_to choice_url( @item.item_type.name ), notice: 'Item was successfully updated.'
      else
        get_categories(@item.category.root.name)
        render action: 'edit'
      end
    else
      do_stocks unless params[:item][:stock_level].blank?
      redirect_to items_url( stock: true, item_id: @item.id, option: params[:option], grouping: params[:grouping], name: params[:name] ), notice: 'Stocks updated.'
    end
  end

  # DELETE /items/1
  def destroy
    item_type = @item.item_type.name
    @item.variants.where("item_id = ? AND domain = ?", @item_id, current_tenant.domain).destroy_all
    @item.destroy
    redirect_to choice_url( item_type ), notice: 'Item was successfully updated.'
  end

  private
    def get_stock_bases
      @stock_bases = Item.where(stock_item: true).order(:name)
      @stock_bases = @stock_bases.where('id <> ?', @item.id) unless @item.id.blank?
    end

    def do_stocks
      stock_date = params[:item][:stock_date].blank? ? Date.today : params[:item][:stock_date]
      stock = @item.stocks.where(stock_date: stock_date)
      if params[:option].present?
        stock = stock.where(item_option: params[:option])
        option = params[:option]
      else
        option = nil
      end
      if !stock.empty?
        stock.first.update( stock_level: params[:item][:stock_level])
      else
        @item.stocks.create(stock_date: stock_date, stock_level: params[:item][:stock_level], item_option: option)
      end
    end

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
    sups.each do |sup|
      @item.supplies.create(supplier_id: sup) unless ( sup.blank? or supset.include?(sup))
    end
  end


end
