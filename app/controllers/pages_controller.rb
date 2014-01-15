class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  # GET /pages
  def index
    @pages = Page.all
  end

  # GET /pages/1
  def show
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  def create
    @page = Page.new(params[:page])
    @page.user_id = current_user.id
    if @page.save
      redirect_to pages_url, notice: 'Page was successfully updated.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /pages/1
  def update
    if @page.update(params[:page])
      redirect_to pages_url, notice: 'Page was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /pages/1
  def destroy
    @page.destroy
    redirect_to pages_url, notice: 'Page was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = params[:code].present? ? Page.find_by_code(params[:id]) : Page.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def page_params
    @current_resource ||= @page
  end
end
