class MessagesController < ApplicationController

  before_action :set_message, only: [:show, :destroy]

  def index
    @messages = Message.all?
  end

  def create
    @message = Message.new(params[:message])
    @message.created_at = Time.now
    @message.message_type = 'adhoc'
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