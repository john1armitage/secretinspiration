class Transfer < ActiveRecord::Base

  belongs_to :bank
  belongs_to :recipient

  has_many  :postings, as: :postable, dependent: :destroy

end
