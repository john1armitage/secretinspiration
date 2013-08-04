class ItemTypesController < ApplicationController
  before_action :set_item_type, only: [:show, :edit, :update, :destroy]
#  before_action :set_form, only: [:new, :edit]

  # GET /item_types
  def index
    @item_types = ItemType.order(:rank, :name).all
  end

  # GET /item_types/1
  def show
  end

  # GET /item_types/new
  def new
    @item_type = ItemType.new
  end

  # GET /item_types/1/edit
  def edit
  end

  # POST /item_types
  def create
    @item_type = ItemType.new(params[:item_type])
    @item_type.blank_fields
    if @item_type.save
      redirect_to item_types_url, notice: 'Item type was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /item_types/1
  def update
    @item_type.blank_fields
    if @item_type.update(params[:item_type])
      redirect_to item_types_url, notice: 'Item type was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /item_types/1
  def destroy
    @item_type.destroy
    redirect_to item_types_url, notice: 'Item type was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_type
      @item_type = ItemType.find(params[:id])
    end

  def read_fields

  end

  #def store_field
  #  get_collections
  #  @collections.each do |field|
  #    selected = []
  #    if params[ field.name ].present?
  #      params[field.name].each do |k,v|
  #        # params[:sizes].each do |k,v|
  #        selected << k
  #      end
  #    end
  #    eval( "params[:variant][:#{field.name}] = selected.join('-')" )
  #  end
  #end

    def current_resource
      @current_resource ||= ItemType.find(params[:id])  if params[:id]
    end
end
