class WelcomeController < ApplicationController

  #before_action :set_welcome, only: [:show, :edit, :update, :destroy]

  # GET /welcome
  def index

  end

  ## GET /welcome/1
  #def show
  #end
  #
  ## GET /welcome/new
  #def new
  #  @welcome = Welcome.new
  #end
  #
  ## GET /welcome/1/edit
  #def edit
  #end
  #
  ## POST /welcome
  #def create
  #  @welcome = Welcome.new(welcome_params)
  #
  #  if @welcome.save
  #    redirect_to @welcome, notice: 'Welcome was successfully created.'
  #  else
  #    render action: 'new'
  #  end
  #end
  #
  ## PATCH/PUT /welcome/1
  #def update
  #  if @welcome.update(welcome_params)
  #    redirect_to @welcome, notice: 'Welcome was successfully updated.'
  #  else
  #    render action: 'edit'
  #  end
  #end
  #
  ## DELETE /welcome/1
  #def destroy
  #  @welcome.destroy
  #  redirect_to welcomes_url, notice: 'Welcome was successfully destroyed.'
  #end
  #
  #private
  #  # Use callbacks to share common setup or constraints between actions.
  #  def set_welcome
  #    @welcome = Welcome.find(params[:id])
  #  end
  #
  #  # Only allow a trusted parameter "white list" through.
  #  def welcome_params
  #    params.require(:welcome).permit(:index)
  #  end
end
