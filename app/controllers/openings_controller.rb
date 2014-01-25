class OpeningsController < ApplicationController
  before_action :set_opening, only: [:show, :edit, :update, :destroy]

  # GET /openings
  def index
    @openings = Opening.all
  end

  # GET /openings/1
  def show
  end

  # GET /openings/new
  def new
    @opening = Opening.new
    @opening.repeat = 1
    @opening.frequency = 'day'
    @opening.status = 'closed'
  end

  # GET /openings/1/edit
  def edit
  end

  # POST /openings
  def create
    @opening = Opening.new(params[:opening])

    if @opening.save
      redirect_to openings_url, notice: 'Opening was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /openings/1
  def update
    if @opening.update(params[:opening])
      redirect_to openings_url, notice: 'Opening was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /openings/1
  def destroy
    @opening.destroy
    redirect_to openings_url, notice: 'Opening was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_opening
      @opening = Opening.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @opening
  end
end
