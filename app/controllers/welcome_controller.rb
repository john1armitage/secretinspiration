class WelcomeController < ApplicationController

  # GET /welcome
  def index
  end

  def edit
    # p "SESSION"
    # p request.remote_addr
    # p request.remote_ip
    # p request.env['HTTP_X_REAL_IP']
    #
    # p request
    # if request.remote_ip.include?(CONFIG[:home_network]) || request.remote_addr == '127.0.0.1'
    #   redirect_to login_url(remote: params[:remote])
    # end
  end

  def update
    # p "REMOTE"
    # p params[:remote]
    # p CONFIG[:remote]
    if params[:remote].present? && params[:remote] == CONFIG[:remote]
      redirect_to login_url, flash: { remote: params[:remote] }
    else
      redirect_to root_url
    end
  end

end
