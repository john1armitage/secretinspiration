class Apportion < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :account
end
