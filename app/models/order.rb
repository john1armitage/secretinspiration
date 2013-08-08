class Order < ActiveRecord::Base

  monetize :net_total_cents, :allow_nil => true,
           :numericality => {
               :greater_than => 0
           }
  monetize :tax_total_cents, :allow_nil => true
  monetize :adjustment_total_cents, :allow_nil => true
  monetize :discount_cents, :allow_nil => true

  has_many :line_items, as: :ownable, dependent: :destroy
  has_many :allocations
  has_many :payments, through: :allocations
  has_many :depreciations

  has_many  :postings, as: :postable, dependent: :destroy

  belongs_to :account
  belongs_to :user
  belongs_to :customer
  belongs_to :supplier


  before_validation :check_account
  before_save :get_totals

  accepts_nested_attributes_for :line_items, :reject_if =>  proc { |att| att['variant_name'].blank? and att['desc'].blank? },
                                :allow_destroy => true
  validates_associated :line_items


  validates_presence_of :supplier_name
  validates_presence_of :effective_date
  validates_numericality_of :net_total, :unless => :state_incomplete
  validates_numericality_of :tax_total, :allow_nil => true
  validates_numericality_of :adjustment_total, :allow_nil => true

  validates_presence_of :account, :net_total, :desc, :if => :quick?

  def state_incomplete
    state == 'incomplete' or state == 'ordered'
  end

  def check_account
    line_items.each do |line_item|
      line_item.account_id = account_id if ( line_item.account_id.blank? and !line_item.variant_name.blank? )
    end
  end

  def quick?
    quick
  end

  def get_totals
    nt = line_items.map(&:net_total_item).sum
    tt = line_items.map(&:tax_total_item).sum
    self.net_total = nt unless nt.to_d == 0
    self.tax_total = tt unless tt.to_d == 0
  end

  def supplier_name
    supplier.try(:name)
  end

  def supplier_name=(name)
    self.supplier = Supplier.find_or_create_by(:name => name) if name.present?
  end

  def customer_name
    customer.try(:name)
  end

  def customer_name=(name)
    self.customer = Customer.find_or_create_by(:name => name) if name.present?
  end

end
