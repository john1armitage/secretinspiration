class Account < ActiveRecord::Base

  # monetize :opening_balance_cents, :allow_nil => true
  def opening_balance
    opening_balance_cents / 100.00 if opening_balance_cents
  end
  def opening_balance=(val)
    self.opening_balance_cents = val ? val.to_d * 100.00 : 0
  end


  has_ancestry :cache_depth => true, :orphan_strategy => :adopt

  has_many :accounts
  has_many :posts, dependent: :nullify
  has_many :payments, dependent: :nullify
  has_many :apportions
  belongs_to :accountable, class_name: 'Supplier'

  belongs_to :root, :class_name => 'Account'

  after_validation :hack_root

  validates :name, uniqueness: true, presence: true
  validates :code, uniqueness: true, presence: true

  before_save :set_ancestors

  #default_scope { order('name') }

  def set_ancestors
    self.root_id = ( ancestry.blank? ?  id : ancestry.gsub(/\/.+/, '') )
#    self.root_id = ancestry.gsub(/\/.+/, '')
    self.account_id = ancestry.gsub(/.+\//, '') if ancestry
  end

  def hack_root
    if ancestry == '0'
      self.ancestry = nil
    end
  end

end
