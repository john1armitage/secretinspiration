class UsersController < ApplicationController

  # load_and_authorize_resource

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def page_title
    "Woof #{action_name}"
  end

  def index
    @users = User.all
    flash[:warning] = "Error"
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to users_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to users_url, notice: "Updated profile."
    else
      render "new"
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: "User deleted"
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def current_resource
    @current_resource ||= User.find(params[:id])  if params[:id]
  end
    #def user_params
  #  params.require(:user).permit(:email, :username, :password, :password_confirmation)
  #end

end
