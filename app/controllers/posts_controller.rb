class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @financials = Element.where(kind: 'financial').order(:rank)
    @groupings = Post.joins("INNER JOIN accounts ON posts.grouping_id = accounts.id").select('accounts.name AS name', 'posts.grouping_id AS id, accounts.code').order('accounts.code').uniq
    @accounts = Account.joins(:posts).order("name").select('name', 'accounts.id').uniq
    @accountables = Supplier.joins(:posts). where("posts.accountable_type = 'Supplier' AND suppliers.id = posts.accountable_id").order("name").select('name', 'posts.accountable_id AS id','rank').uniq
    @accountables += Employee.joins(:posts). where("posts.accountable_type = 'Employee' AND employees.id = posts.accountable_id").order("reference").select('reference AS name','first_name','last_name', 'posts.accountable_id AS id').uniq
    @accountables += Bank.joins(:posts). where("posts.accountable_type = 'Bank' AND banks.id = posts.accountable_id").order("reference").select('reference','name', 'posts.accountable_id AS id', 'rank').uniq
    #if params[:q]
    #  params[:q][:debit_amount_cents_gteq] = 100 * params[:q][:debit_amount_cents_gteq].to_d
    #  params[:q][:debit_amount_cents_lteq] = 100 * params[:q][:debit_amount_cents_lteq].to_d
    #  params[:q][:credit_amount_cents_gteq] = 100 * params[:q][:credit_amount_cents_gteq].to_d
    #  params[:q][:credit_amount_cents_lteq] = 100 * params[:q][:credit_amount_cents_lteq].to_d
    #end
    list_order = ''

    unless params[:financial].present? && !params[:financial].blank?
      #params[:financial] = 'FQ to date'
    end

    if params[:financial].present?
      @period =  params[:financial]
      case @period
        when 'FY to date'
          period = fy_to_date
          params[:q][:account_date_gteq] = period[0]
          params[:q][:account_date_lteq] = period[1]
        when 'FQ to date'
          period = fq_to_date
          params[:q][:account_date_gteq] = period[0]
          params[:q][:account_date_lteq] = period[1]
        when 'Last FY'
          period = last_fy
          params[:q][:account_date_gteq] = period[0]
          params[:q][:account_date_lteq] = period[1]
        when 'Last FQ'
          period = last_fq
          params[:q][:account_date_gteq] = period[0]
          params[:q][:account_date_lteq] = period[1]
        else
          params[:q][:account_date_gteq] = ''
          params[:q][:account_date_lteq] = ''
      end
    end

    unless params[:q].present?
      limit = 100
      list_order = 'DESC'
    else
      limit = params[:limit] || 100
    end
    if params[:q].present?
      params[:q][:debit_amount_cents_gteq] = 1 unless params[:q][:debit_amount_cents_lteq].blank?
      params[:q][:credit_amount_cents_gteq] = 1 unless params[:q][:credit_amount_cents_lteq].blank?
      # params[:q][:credit_amount_cents_gteq] = 100 * params[:q][:credit_amount_cents_gteq].to_i unless params[:q][:credit_amount_cents_gteq].blank?
      # unless params[:q][:debit_amount_cents_lteq].blank?
      #   params[:q][:debit_amount_cents_lteq] = 100 * params[:q][:debit_amount_cents_lteq].to_i
      #   params[:q][:debit_amount_cents_gt] = 0
      # end
      # params[:q][:credit_amount_cents_lteq] = 100 * params[:q][:credit_amount_cents_lteq].to_i unless params[:q][:credit_amount_cents_lteq].blank?
    end
    @q = Post.search(params[:q])
    # @q.debit_amount_cents_gteq = 0 unless params[:q][:debit_amount_cents_lteq].blank?
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
