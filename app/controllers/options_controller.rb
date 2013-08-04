class OptionsController < ApplicationController
  before_action :set_option, only: [:show, :edit, :update, :destroy]

  # GET /options
  def index
    if params[:kind].present?
      @options = Option.where(kind: params[:kind] ).order(:rank, :name)
    else
      @options = Option.all.order(:kind, :rank, :name)
    end
  end

  # GET /options/1
  def show
  end

  # GET /options/new
  def new
    @option = Option.new
  end

  # GET /options/1/edit
  def edit
  end

  # POST /options
  def create
    @option = Option.new(params[:option])

    if @option.save
      redirect_to options_url(kind: @option.kind), notice: 'Create option was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /options/1
  def update
    if @option.update(params[:option])
      redirect_to options_url(kind: @option.kind), notice: 'Option was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /options/1
  def destroy
    @option.destroy
    redirect_to options_url, notice: 'Option was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_option
      @option = Option.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @option
  end
end
