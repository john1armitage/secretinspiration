class Financial < ActiveRecord::Base

  monetize :debit_amount_cents
  monetize :credit_amount_cents

  belongs_to :daily

  default_scope { order('event_date DESC, created_at DESC') }

end
