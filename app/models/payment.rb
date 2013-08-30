class Payment < ActiveRecord::Base

  include AccountPosting

  monetize :amount_cents
  monetize :home_amount_cents

  has_many :allocations, dependent: :destroy
  has_many :orders, through: :allocations

  has_many  :postings, as: :postable, dependent: :destroy
  belongs_to :bank

  belongs_to :payable, polymorphic: true

  belongs_to :account

  accepts_nested_attributes_for :allocations, :allow_destroy => true

  after_create :create_postings

  def create_postings
    bank_account = Account.find_by_name( bank.name ).id
    create_posting( 'Payment', id, false, amount_cents, Account.find_by_name('Accounts Payable').id, payable_type, payable_id, false, payment_date)
    create_posting( 'Payment', id, true, amount_cents, bank_account, payable_type, payable_id, false, payment_date)
  end

end
