class Financial < ActiveRecord::Base

  attr_accessor :amount

  has_many  :posts, as: :postable, dependent: :destroy

  belongs_to :account

  # before_save :nil_to_zero
  #
  # monetize :debit_amount_cents, :allow_nil => true
  # monetize :credit_amount_cents, :allow_nil => true
  # monetize :tax_home_cents, :allow_nil => true

  # def nil_to_zero
  #   self.debit_amount_cents = 0 if debit_amount == nil
  #   self.credit_amount_cents = 0 if credit_amount == nil
  # end
  #
  def debit_amount
    debit_amount_cents / 100.00 if debit_amount_cents
  end
  def debit_amount=(val)
    self.debit_amount_cents = val ? val.to_d * 100.00 : 0
  end

  def credit_amount
    credit_amount_cents / 100.00 if credit_amount_cents
  end
  def credit_amount=(val)
    self.credit_amount_cents = val ? val.to_d * 100.00 : 0
  end

  def tax_home
    tax_home_cents / 100.00
  end
  def tax_home=(val)
    self.tax_home_cents = val ? val.to_d * 100.00 : 0
  end

  validates :summary, presence: true
  validates :desc, presence: true
  validates :classification, presence: true
#  validates :account_id, presence: true

  validate :amount_included?

  before_save :ensure_reference, :set_credit

  belongs_to :daily

  has_many :depreciations

  #default_scope { order('event_date DESC, created_at DESC') }

  def amount_included?
    unless ((debit_amount ? debit_amount.to_d : 0.00 ) + (credit_amount ? credit_amount.to_d : 0.00 ) > 0.00)
      self.credit_amount = self.debit_amount = nil
      errors.add(:credit_amount, "One or ...")
      errors.add(:debit_amount, "... the Other")
    end
  end

  def ensure_reference
   self.desc = summary if desc.blank?
  end

  def set_credit
    if credit_amount && credit_amount > 0.00
      self.credit = true
      self.debit_amount = nil
    else
      self.credit = false
      self.credit_amount = nil
    end
  end

end
