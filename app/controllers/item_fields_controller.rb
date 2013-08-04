class ItemFieldsController < ApplicationController
  before_action :set_item_field, only: [:show, :edit, :update, :destroy]

  # GET /item_fields
  def index
    if params[:item_type].present?
      @item_fields = ItemField.where(:item_type_id => params[:item_type_id]).order(:name)
    else
      @item_fields = ItemField.order(:options, :name)
    end

  end

  # GET /item_fields/1
  def show
  end

  # GET /item_fields/new
  def new
    @item_field = ItemField.new
    @item_field.item_type = params[:item_type_id] if params[:item_type_id].present?
  end

  # GET /item_fields/1/edit
  def edit
  end

  # POST /item_fields
  def create
    @item_field = ItemField.new(item_field_params)

    if @item_field.save
      redirect_to item_fields_url(:item_type_id => params[:item_field][:item_type_id]), notice: 'Item field was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /item_fields/1
  def update
    if @item_field.update(item_field_params)
      redirect_to  item_fields_url(:item_type_id => params[:item_field][:item_type_id]), notice: 'Item field was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /item_fields/1
  def destroy
    item_type = @item_field.item_type
    @item_field.destroy
    redirect_to item_fields_url(:item_type => item_type), notice: 'Item field was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_field
      @item_field = ItemField.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def item_field_params
      params.require(:item_field).permit(:name, :field_type, :options, :rank)
    end
end
