class Posting < ActiveRecord::Base

  monetize :debit_amount_cents
  monetize :credit_amount_cents

  belongs_to :postable, polymorphic: true
  belongs_to :accountable, polymorphic: true
  belongs_to :account
end
