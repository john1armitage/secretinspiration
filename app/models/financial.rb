class Financial < ActiveRecord::Base

  attr_accessor :amount

  has_many  :posts, as: :postable, dependent: :destroy

  monetize :debit_amount_cents, :allow_nil => true
  monetize :credit_amount_cents, :allow_nil => true
  monetize :tax_home_cents, :allow_nil => true

  validates :summary, presence: true

  validate :amount_included?

  # validates :debit_amount_cent, presence: true, unless: :check_credit_amount
  # validates :credit_amount_cent, presence: true, unless: :check_debit_amount

  before_save :ensure_reference, :set_credit

  belongs_to :daily

  default_scope { order('event_date DESC, created_at DESC') }

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
