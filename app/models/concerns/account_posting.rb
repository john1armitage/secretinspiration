module AccountPosting
  extend ActiveSupport::Concern
  private
  def create_posting(postable_type, postable_id, credit, amount, account_id, accountable_type, accountable_id, contra, posting_date)
    post = Posting.new
    post.event_date = posting_date
    post.postable_type = postable_type
    post.postable_id = postable_id
    unless credit && contra || !credit && !contra
      post.credit_amount_cents = amount
    else
      post.debit_amount_cents = amount
    end
    post.account_id = account_id
    post.accountable_type = accountable_type
    post.accountable_id = accountable_id
    post.save
  end

  def create_post(account_date, desc, postable_type, postable_id, debit_amount, credit_amount, account_id, accountable_type, accountable_id)
    post = Post.new
    post.account_date = account_date
    post.desc = desc
    post.postable_type = postable_type
    post.postable_id = postable_id
    post.credit_amount_cents = credit_amount
    post.debit_amount_cents = debit_amount
    post.account_id = account_id
    post.accountable_type = accountable_type
    post.accountable_id = accountable_id
    post.save
  end
end