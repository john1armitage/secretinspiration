class Account < ActiveRecord::Base

  monetize :opening_balance_cents, :allow_nil => true

  has_ancestry :cache_depth => true, :orphan_strategy => :adopt

  has_many :accounts
  has_many :postings, dependent: :nullify
  has_many :payments, dependent: :nullify
  has_many :apportions

  belongs_to :root, :class_name => 'Account'

  after_validation :hack_root

  validates :name, uniqueness: true, presence: true
  validates :code, uniqueness: true, presence: true

  before_save :set_ancestors

  default_scope { order('code ASC') }

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
