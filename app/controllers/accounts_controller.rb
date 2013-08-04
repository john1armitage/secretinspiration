class AccountsController < ApplicationController

  respond_to :html, :json

  before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts
  def index
    @accounts = Account.order(:code).all
    respond_with @accounts
  end

  # GET /accounts/1
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new( :parent_id => params[:parent_id] )
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_to accounts_url, notice: 'Account was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      redirect_to accounts_url, notice: 'Account was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
    redirect_to accounts_url, notice: 'Account was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
      params.require(:account).permit(:name, :code, :ancestry, :opening_balance)
    end

end
