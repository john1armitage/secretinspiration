class LineItem < ActiveRecord::Base

  monetize :net_item_cents, :allow_nil => true
  monetize :tax_item_cents, :allow_nil => true
  monetize :local_net_item_cents, :allow_nil => true
  monetize :local_tax_item_cents, :allow_nil => true
  monetize :net_total_item_cents, :allow_nil => true
  monetize :tax_total_item_cents, :allow_nil => true
  monetize :discount_cents, :allow_nil => true

  has_ancestry :cache_depth => true, :orphan_strategy => :destroy

  belongs_to :ownable, polymorphic: true

  belongs_to :variant
  belongs_to :option
  belongs_to :account

  before_validation :process_variant
  before_validation :process_local
  before_validation :get_totals
  #
  validates_presence_of :desc, :unless => :linked_id?
  validates_presence_of :account, :unless => :cart_or_blank?
  validates_numericality_of :net_item, :allow_nil => true
  validates_numericality_of :tax_item, :allow_nil => true
  validates_numericality_of :quantity

  fields =  Element.where( kind: 'item_choices')
  fields.each do |field|
    store_accessor :choices, field.name.downcase
  end

  def process_local
    self.net_item = local_net_item / exchange_rate
    self.tax_item = local_tax_item / exchange_rate
  end

  def process_variant
    self.account_id = variant.item.item_type.account_id if variant_id.present?
    self.quantity = 1 unless quantity.to_i > 0
  end

  def get_totals
    self.net_item ||= 0
    self.tax_item ||= 0
    self.net_total_item = quantity * net_item.to_d
    self.tax_total_item = quantity * tax_item.to_d
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
