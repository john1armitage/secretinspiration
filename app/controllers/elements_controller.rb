class ElementsController < ApplicationController
  before_action :set_element, only: [:show, :edit, :update, :destroy]

  # GET /elements
  def index
    @q = Element.search(params[:q])

    @kinds = Element.where(kind: 'kind').select("id, name, initcap(regexp_replace(name, '_', ' ', 'g')) as title" ).order(:name).uniq

    @q.kind_eq = 'kind' unless params[:q].present?

    # @elements = Element.all.order(:kind, :rank, :name)
    @elements = @q.result(distinct: true).order(:kind, :rank, :name)
    @elements = @elements.where( :kind => params[:kind] )  if params[:kind].present?
  end

  # GET /elements/1
  def show
  end

  # GET /elements/new
  def new
    @element = Element.new
    eval("@element.#{current_tenant.domain} = true")
    @element.kind = params[:kind] if params[:kind].present?
  end

  # GET /elements/1/edit
  def edit
  end

  # POST /elements
  def create
    @element = Element.new(params[:element])

    if @element.save
      redirect_to new_element_url(:kind => @element.kind), notice: 'Element was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /elements/1
  def update
    if @element.update(params[:element])
      redirect_to elements_url(:kind => @element.kind), notice: 'Element was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /elements/1
  def destroy
    kind = @element.kind
    @element.destroy
    redirect_to elements_url(:kind => kind ), notice: 'Element was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_element
      @element = Element.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @item
  end
end
