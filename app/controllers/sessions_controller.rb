class SessionsController < ApplicationController

  def new
    # p "SESSION"
    # p flash[:remote]
    # p CONFIG[:remote]
    # p request.remote_addr
    # p request.remote_ip
    # p request.env["HTTP_X_FORWARDED_FOR"]
    #
    # p request
    unless CONFIG[:allowed_hosts].include?(request.remote_ip)  || (flash[:remote].present? && flash[:remote] == CONFIG[:remote])
    # unless CONFIG[:allowed_hosts].include?(request.remote_ip) || request.remote_addr == '127.0.0.1' || (flash[:remote].present? && flash[:remote] == CONFIG[:remote])
      p CONFIG[:allowed_hosts]
      p request.remote_ip
      p request.remote_addr
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
