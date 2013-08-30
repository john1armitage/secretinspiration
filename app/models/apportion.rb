class Apportion < ActiveRecord::Base

  include AccountPosting

  belongs_to :receipt
  belongs_to :account

  has_many :postings, as: :postable, dependent: :destroy

 # after_create :post

  def post
    create_posting( 'Receipt', receipt.id, true, amount_cents, account_id, receipt.receivable_type, receipt.receivable_id, false, receipt.receipt_date)
  end

end
