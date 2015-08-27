class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @account_groups = Account.joins(:posts).where(ancestry_depth: 1).order("name").select('name', 'accounts.id').uniq
    @accounts = Account.joins(:posts).order("name").select('name', 'accounts.id').uniq
    @accountables = Supplier.joins(:posts). where('suppliers.id = posts.accountable_id').order("name").select('name', 'suppliers.id', 'rank').uniq
    #if params[:q]
    #  params[:q][:debit_amount_cents_gteq] = 100 * params[:q][:debit_amount_cents_gteq].to_d
    #  params[:q][:debit_amount_cents_lteq] = 100 * params[:q][:debit_amount_cents_lteq].to_d
    #  params[:q][:credit_amount_cents_gteq] = 100 * params[:q][:credit_amount_cents_gteq].to_d
    #  params[:q][:credit_amount_cents_lteq] = 100 * params[:q][:credit_amount_cents_lteq].to_d
    #end
    list_order = ''
    unless params[:q].present?
      limit = 25
      list_order = 'DESC'
    else
      limit = params[:limit] || 100
    end

    @q = Post.search(params[:q])
    @posts = @q.result(distinct: true).limit(limit).order("account_date #{list_order}, created_at")
    @debits = @posts.sum('debit_amount_cents').to_d / 100
    @credits = @posts.sum('credit_amount_cents').to_d / 100
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def current_resource
      @current_resource ||= @post
    end
end
