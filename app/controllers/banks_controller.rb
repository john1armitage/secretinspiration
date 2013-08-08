class BanksController < ApplicationController
  before_action :set_bank, only: [:show, :edit, :update, :destroy]

  # GET /banks
  def index
    @banks = Bank.all
  end

  # GET /banks/1
  def show
  end

  # GET /banks/new
  def new
    @bank = Bank.new
  end

  # GET /banks/1/edit
  def edit
  end

  # POST /banks
  def create
    @bank = Bank.new(params[:bank])

    if @bank.save
      redirect_to banks_url, notice: 'Bank was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /banks/1
  def update
    if @bank.update(params[:bank])
      redirect_to banks_url, notice: 'Bank was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /banks/1
  def destroy
    @bank.destroy
    redirect_to banks_url, notice: 'Bank was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank
      @bank = Bank.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @bank
  end
end
