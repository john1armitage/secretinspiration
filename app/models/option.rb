class Option < ActiveRecord::Base

  monetize :price_cents, :allow_nil => true

  has_many :line_items

end
