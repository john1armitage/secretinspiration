class PostingsController < ApplicationController
  before_action :set_posting, only: [:show]

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

  def search
    index
    render :index
  end

  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_posting
      @posting = Posting.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def current_resource
    @current_resource ||= @posting
  end
end
