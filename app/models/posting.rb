class Posting < ActiveRecord::Base

  monetize :home_amount, :debit_amount, :credit_amount

  belongs_to :postable, polymorphic: true

end
