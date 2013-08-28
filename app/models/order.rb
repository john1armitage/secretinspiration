class Order < ActiveRecord::Base

  include AccountPosting

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
  #before_validation :get_totals

  #accepts_nested_attributes_for :line_items, :reject_if =>  proc { |att| att['variant_name'].blank? and att['desc'].blank? },
  accepts_nested_attributes_for :line_items, :reject_if =>  proc { |att| att['quantity'].blank?  },
                                :allow_destroy => true
  validates_associated :line_items

  validates_presence_of :supplier_name, :message => 'is required'
  validates_presence_of :effective_date, :message => 'is required'
  validates_numericality_of :net_total, :greater_than => 0, :message => 'is required' #, :unless => :state_incomplete
  validates_numericality_of :tax_total, :allow_nil => true
  validates_numericality_of :adjustment_total, :allow_nil => true

  validates_presence_of :account, :net_total, :desc, :if => :quick?, :message => 'is required'

  scope :outgoings, ->(id) { where.not( supplier_id: id ) }

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

  #def get_totals
  #  nt = line_items.map(&:net_total_item).sum
  #  tt = line_items.map(&:tax_total_item).sum
  #  self.net_total = nt # unless nt.to_d == 0
  #  self.tax_total = tt # unless tt.to_d == 0
  #end
  #
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

  def commit
    p "commit"
    home_supplier ? home_posting : posting
  end

  def home_posting
    contra = !contra
    #if line_items.present?
    #  p "line_item"
    #  line_items.each do |line_item|
    #    p "line_item"
    #    Order.transaction do
    #      p "transaction"
    #      create_posting( 'LineItem', line_item.id, false, line_item.net_total_item_cents, Account.find(line_item.account_id).parent.id, 'Account', line_item.account_id, contra)
    #      if line_item.tax_total_item_cents.to_i > 0
    #        vat_control = Account.find_by_name('VAT Control').id
    #        create_posting( 'LineItem', line_item.id, false, line_item.tax_total_item_cents, vat_control, 'Account', vat_control, contra)
    #      end
    #    end
    #  end
    #  create_posting( 'Order', id, true, (net_total_cents + tax_total_cents), Account.find_by_name('Accounts Receivable').id, 'Customer', customer_id, contra)
    #  self.state = 'committed'
    #else
      p "quick"
      Order.transaction do
        p "transaction"
        create_posting( 'Order', id, false, net_total_cents, Account.find(account_id).parent.id, 'Account', account_id, contra)
        create_posting( 'Order', id, true, (net_total_cents + tax_total_cents), Account.find_by_name('Accounts Receivable').id, 'Customer', customer_id, contra)
        if tax_total_cents > 0
          vat_control = Account.find_by_name('VAT Control').id
          create_posting( 'Order', id, false, tax_total_cents, vat_control, 'Account', vat_control, contra)
        end
        self.state = 'committed'
      end
    #end
  end

  def posting
    if line_items.present?
      p "line_item"
      vat_control = Account.find_by_name('VAT Control').id
      Order.transaction do
        line_items.order(:account_id).each do |line_item|
          p "line_item"
            create_posting( 'LineItem', line_item.id, false, line_item.net_total_item_cents, Account.find(line_item.account_id).parent.id, 'Account', line_item.account_id, contra, effective_date)
          end
        if tax_total_cents.to_i > 0
          create_posting( 'Order', id, false, tax_total_cents, vat_control, 'Account', vat_control, contra, effective_date)
        end
        create_posting( 'Order', id, true, (net_total_cents + tax_total_cents), Account.find_by_name('Accounts Payable').id, 'Supplier', supplier_id, contra, effective_date)
        self.state = 'committed'
      end
    else
      p "quick"
      Order.transaction do
        p "transaction"
        create_posting( 'Order', id, false, net_total_cents, Account.find(account_id).parent.id, 'Account', account_id, contra, effective_date)
        create_posting( 'Order', id, true, (net_total_cents + tax_total_cents), Account.find_by_name('Accounts Payable').id, 'Supplier', supplier_id, contra, effective_date)
        if tax_total_cents > 0
          vat_control = Account.find_by_name('VAT Control').id
          create_posting( 'Order', id, false, tax_total_cents, vat_control, 'Account', vat_control, contra, effective_date)
        end
        self.state = 'committed'
      end
    end
  end

  #def create_posting(postable_type, postable_id, credit, amount, account_id, accountable_type, accountable_id, contra)
  #  p "Account #{accountable_type} amount #{amount} credit #{credit}"
  #  p "Account #{account_id}"
  #  post = Posting.new
  #  post.event_date = effective_date
  #  post.postable_type = postable_type
  #  post.postable_id = postable_id
  #  if credit && !contra || !credit && contra
  #    p "credit"
  #    post.credit_amount_cents = amount
  #  else
  #    p "debit"
  #    p amount
  #    post.debit_amount_cents = amount
  #  end
  #  post.account_id = account_id
  #  post.accountable_type = accountable_type
  #  post.accountable_id = accountable_id
  #  p post
  #  post.save
  #end

end
