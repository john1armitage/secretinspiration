class StocksController < ApplicationController
  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  # GET /stocks
  # GET /stocks.json
  def index
    if params[:item_id].present?
      @item_id = params[:item_id]
      @stocks = Item.find(params[:item_id]).stocks
    else
      @stocks = Stock.all
    end
    @stocks = @stocks.order('stock_date DESC')
    if params[:option].present?
      # @option = params[:option]
      @stocks = @stocks.where(item_option: params[:option] )
    end
    @option = params[:option].present? ? params[:option] : nil
    render 'index.js.erb'
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: @stocks }
    # end
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock }
    end
  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks
  # POST /stocks.json
  def create
    @stock = Stock.new(stock_params)

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: 'Stock was successfully created.' }
        format.json { render json: @stock, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1
  # PATCH/PUT /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @item_id = @stock.item_id
    @option = @stock.item_option
    @stock.destroy
    @stocks = Item.find(@item_id).stocks.where(item_option: @option).order('stock_date DESC')
    render 'index.js.erb'
    # respond_to do |format|
    #   format.html { redirect_to stocks_url }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_params
      params.require(:stock).permit(:index, :delete)
    end
end
