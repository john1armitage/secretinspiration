class BroadcastsController < ApplicationController
  before_action :set_broadcast, only: [:show, :edit, :update, :destroy]

  # GET /broadcasts
  def index
    @broadcasts = Broadcast.order('event_date DESC').all
  end

  def blog
    @broadcasts = Broadcast.joins(:topic).where('publish = true and blog = true and topics.name = ?', params[:name])
    @broadcasts = ( params[:name]) == 'event' ? @broadcasts.order('event_date, event_time ASC') : @broadcasts.order('updated_at DESC')
  end

  # GET /broadcasts/1
  def show
    render 'aside' if params[:aside].present?
  end

  # GET /broadcasts/new
  def new
    @broadcast = Broadcast.new
    @broadcast.blog = true
    @broadcast.publish = true
    @broadcast.category = 'blog'
    @broadcast.repeat = 1
  end

  # GET /broadcasts/1/edit
  def edit
  end

  # POST /broadcasts
  def create
    @broadcast = Broadcast.new(params[:broadcast])
    @broadcast.user_id = current_user.id
    if @broadcast.save
      redirect_to broadcasts_url, notice: 'Broadcast was successfully updated.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /broadcasts/1
  def update
    if @broadcast.update(params[:broadcast])
      redirect_to broadcasts_url, notice: 'Broadcast was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /broadcasts/1
  def destroy
    @broadcast.destroy
    redirect_to broadcasts_url, notice: 'Broadcast was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_broadcast
      @broadcast = params[:code].present? ? Broadcast.find_by_code(params[:id]) : Broadcast.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def broadcast_params
    @current_resource ||= @broadcast
  end
end
