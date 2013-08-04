class TabelsController < ApplicationController
  before_action :set_tabel, only: [:show, :edit, :update, :destroy]

  # GET /tabels
  def index
    @tabels = Tabel.order('name::INT').all
  end

  # GET /tabels/1
  def show
  end

  # GET /tabels/new
  def new
    @tabel = Tabel.new
  end

  # GET /tabels/1/edit
  def edit
  end

  # POST /tabels
  def create
    @tabel = Tabel.new(tabel_params)

    if @tabel.save
      redirect_to tabels_url, notice: 'Tabel was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /tabels/1
  def update
    if @tabel.update(tabel_params)
      redirect_to tabels_url, notice: 'Tabel was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /tabels/1
  def destroy
    @tabel.destroy
    redirect_to tabels_url, notice: 'Tabel was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tabel
      @tabel = Tabel.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tabel_params
      params.require(:tabel).permit(:name, :variant, :capacity)
    end
end
