class TransfersController < ApplicationController
  before_action :set_transfer, only: [:show, :edit, :update, :destroy, :commit]

  # GET /transfers
  def index
    @transfers = Transfer.all
  end

  # GET /transfers/1
  def show
  end

  # GET /transfers/new
  def new
    @transfer = Transfer.new
    @transfer.transfer_date = cookies[:last_tx_date] || Time.now
  end

  # GET /transfers/1/edit
  def edit
  end

  # POST /transfers
  def create
    @transfer = Transfer.new(params[:transfer])
    bank_currency = @transfer.bank.opening_balance_currency
    recipient_currency = @transfer.recipient.opening_balance_currency
    @transfer.desc = bank_currency + ":" + recipient_currency
    @transfer.exchange_rate =  bank_currency == recipient_currency ? 1 : get_conversion_rate(bank_currency, recipient_currency, 1)
    cookies[:last_tx_date] = @transfer.transfer_date

    if @transfer.save
      redirect_to transfers_url, notice: 'Transfer was successfully created.'
    else
      render action: 'new'
    end
  end

  def commit
    @transfer.commit
    @transfer.save
    redirect_to transfers_url
  end

  # PATCH/PUT /transfers/1
  def update
    if @transfer.update(params[:transfer])
      redirect_to transfers_url, notice: 'Transfer was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /transfers/1
  def destroy
    @transfer.destroy
    redirect_to transfers_url, notice: 'Transfer was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer
      @transfer = Transfer.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @transfer
  end
end
