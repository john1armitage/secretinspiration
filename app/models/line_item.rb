class LineItem < ActiveRecord::Base

  monetize :net_item_cents, :allow_nil => true
  monetize :tax_item_cents, :allow_nil => true
  monetize :net_home_cents, :allow_nil => true
  monetize :tax_home_cents, :allow_nil => true
  monetize :net_total_item_cents, :allow_nil => true
  monetize :tax_total_item_cents, :allow_nil => true
  monetize :discount_cents, :allow_nil => true

  has_ancestry :cache_depth => true, :orphan_strategy => :destroy

  has_one  :posting, as: :postable, dependent: :destroy

  belongs_to :ownable, polymorphic: true

  belongs_to :variant
  belongs_to :option
  belongs_to :account

  before_validation :process_variant
  before_validation :process_home
  #
  validates_presence_of :desc, :unless => :linked_id?
  validates_presence_of :account #, :unless => :cart_or_blank?
  validates_numericality_of :net_item, :greater_than => 0, :message => 'is required' #, :allow_nil => true
  validates_numericality_of :tax_item, :allow_nil => true
  validates_numericality_of :quantity

  fields =  Element.where( kind: 'item_choices')
  fields.each do |field|
    store_accessor :choices, field.name.downcase
  end

  def process_home
    unless exchange_rate.blank?
      self.net_home = net_total_item / exchange_rate
      self.tax_home = tax_total_item / exchange_rate
    end
  end

  def process_variant
    self.account_id = variant.item.item_type.account_id if variant_id.present?
    self.quantity = 1 unless quantity.to_i > 0
  end

  def linked_id?
    variant_id || option_id
  end

  def cart_or_blank?
    ownable_type == 'Cart' || variant_name.blank?
  end

  def check_account
    self.account_id = params[:order][:account_id] if account_id.blank?
  end

  def order_account?
    order.account
  end

  def variant_name
    if variant
      name = variant.try(:name)
      name = variant.item.try(:name) if name == 'default'
    end
    name
  end

  def variant_name=(name)
    if name.blank?
      self.variant_id = nil
    else
      variant = Variant.find_by_name(name)
      unless variant
        item = Item.find_by_name(name)
        if item
          variant = item.variants.find_by_name('default')          #where(name: 'default').first
        else
          self.variant_id = nil
        end
      end
      if variant
        self.variant = variant
        self.desc = variant.item.name
        self.desc += ": #{variant.name}" unless variant.name == 'default'
      end
    end
  end

end
