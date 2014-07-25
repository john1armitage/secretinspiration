class Monthly < ActiveRecord::Base
  monetize :takings_cents, :allow_nil => true
  monetize :credit_card_cents, :allow_nil => true
  monetize :cash_cents, :allow_nil => true
  monetize :tax_cents, :allow_nil => true
  monetize :turnover_cents, :allow_nil => true
  monetize :cash_used_cents, :allow_nil => true
end
