class MessagesController < ApplicationController

  before_action :set_message, only: [:show, :destroy]

  def index
    @messages = Message.all?
  end

  def create
    @message = Message.create(params[:message])
  end

  def destroy
    @message.destroy
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @message
  end


end