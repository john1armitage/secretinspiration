module AccountPosting
  extend ActiveSupport::Concern
  private
  def create_posting(postable_type, postable_id, credit, amount, account_id, accountable_type, accountable_id, contra, posting_date)
    p "Account #{accountable_type} amount #{amount} credit #{credit}"
    p "Account #{account_id}"
    post = Posting.new
    post.event_date = posting_date
    post.postable_type = postable_type
    post.postable_id = postable_id
    if credit && !contra || !credit && contra
      p "credit"
      post.credit_amount_cents = amount
    else
      p "debit"
      p amount
      post.debit_amount_cents = amount
    end
    post.account_id = account_id
    post.accountable_type = accountable_type
    post.accountable_id = accountable_id
    p post
    post.save
  end
end