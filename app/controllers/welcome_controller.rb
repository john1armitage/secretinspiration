class WelcomeController < ApplicationController

  # GET /welcome
  def index
  end

  def edit
    if request.remote_addr.include?(CONFIG[:home_network]) || request.remote_addr == '127.0.0.1'
      redirect_to login_url(remote: params[:remote])
    end
  end

  def update
    if params[:remote].present? && params[:remote] == CONFIG[:remote]
      redirect_to login_url, flash: { remote: params[:remote] }
    else
      redirect_to root_url
    end
  end

end
