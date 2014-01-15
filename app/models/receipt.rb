class Receipt < ActiveRecord::Base

  include AccountPosting

  monetize :amount_cents
  monetize :home_amount_cents

  belongs_to :bank
  belongs_to :order
  has_many :apportions, dependent: :destroy
  has_many :postings, as: :postable, dependent: :destroy

  default_scope { order('receipt_date DESC') }

  def post
    create_posting( 'Receipt', id, true, amount_cents, apportions.first.account_id, receivable_type, receivable_id, false, receipt_date)
    post_bank
  end

  def post_takings
    apportions.each do |apportion|
      create_posting( 'Receipt', id, true, apportion.amount_cents, apportion.account_id, receivable_type, receivable_id, false, receipt_date)
    end
    post_bank
  end

  def post_bank
    bank_account = Account.find_by_name( bank.name ).id
    create_posting( 'Receipt', id, false, amount_cents, bank_account, receivable_type, receivable_id, false, receipt_date)
  end

end
