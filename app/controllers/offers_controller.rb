class OffersController < ApplicationController
  before_action :set_offer, only: [:show, :edit, :update, :destroy]

  # GET /offers
  def index
    @offers = Offer.all
  end

  # GET /offers/1
  def show
  end

  # GET /offers/new
  def new
    @offer = Offer.new
  end

  # GET /offers/1/edit
  def edit
  end

  # POST /offers
  def create
    @offer = Offer.new(params[:offer])

    if @offer.save
      redirect_to offers_url, notice: 'Offer was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /offers/1
  def update
    if @offer.update(params[:offer])
      redirect_to offers_url, notice: 'Offer was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /offers/1
  def destroy
    @offer.destroy
    redirect_to offers_url, notice: 'Offer was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer
      @offer = Offer.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @offer
  end
end
