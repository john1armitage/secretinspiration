class PicsController < ApplicationController
  before_action :set_pic, only: [:show, :edit, :update, :destroy]

  respond_to :html, :js

  # GET /pics
  def index
    get_pics
    @pic = Pic.new
    @pic.viewable_type="Variant"
    @pic.viewable_id = params[:variant_id].to_i
  end

  # GET /pics/1
  def show
  end

  # GET /pics/new
  def new
    @pic = Pic.new
  end

  # GET /pics/1/edit
  def edit
  end

  # POST /pics
  def create
    @pic = Pic.new(pic_params)

    if @pic.save
      redirect_to pics_url(:variant_id => @pic.viewable.id), notice: 'Pic was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /pics/1
  def update
    if @pic.update(pic_params)
      redirect_to @pic, notice: 'Pic was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /pics/1
  def destroy
    @variant = @pic.variant
    @pic.destroy
    redirect_to pics_url, notice: 'Pic was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pic
      @pic = Pic.find(params[:id])
    end

    def get_pics
      @variant = Variant.find( params[:variant_id])
      @pics = @variant.pics.all
    end

    # Only allow a trusted parameter "white list" through.
    def pic_params
      params.require(:pic).permit(:name, :image, :viewable_type, :viewable_id)
    end
end
