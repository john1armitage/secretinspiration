class SessionsController < ApplicationController

  def new
    p "DDDDDDDDDDDDDDDDDDDD"
    p request.remote_addr
    unless request.remote_addr.include?(CONFIG[:home_network]) || request.remote_addr == '127.0.0.1' || (flash[:remote][0].present? && flash[:remote][0] == CONFIG[:remote])
      redirect_to root_url
    end

  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end

    #  session[:user_id] = user.id
      redirect_to root_url, notice: "Logged in!"
    else
      flash.now.alert = "Email or password is invalid"
      render "new"
    end
  end

  def destroy
    cookies.delete(:auth_token)
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end

end
