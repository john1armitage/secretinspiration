class Transfer < ActiveRecord::Base

  include AccountPosting

  monetize :amount_cents,
           :numericality => {
               :greater_than => 0
           }

  belongs_to :bank
  belongs_to :recipient, class_name: 'Bank'

  has_many  :postings, as: :postable, dependent: :destroy

  validates_numericality_of :amount, :greater_than => 0, :message => 'is required'

  def commit
    Transfer.transaction do
      p "transaction"
      bank = Account.find_by_name( Bank.find(bank_id).name)
      recipient = Account.find_by_name( Bank.find(recipient_id).name)
      create_posting( 'Transfer', id, true, amount_cents, bank.parent.id, 'Bank', bank_id, false, transfer_date)
      create_posting( 'Transfer', id, false, amount_cents, recipient.parent.id, 'Bank', recipient_id, false, transfer_date)
      self.state = 'committed'
    end
    #end
  end


end
