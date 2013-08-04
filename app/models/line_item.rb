class LineItem < ActiveRecord::Base

  monetize :net_item_cents
  monetize :tax_item_cents, :allow_nil => true
  monetize :local_net_item_cents, :allow_nil => true
  monetize :local_tax_item_cents, :allow_nil => true
  monetize :net_total_item_cents
  monetize :tax_total_item_cents, :allow_nil => true
  monetize :discount_cents, :allow_nil => true

  has_ancestry :cache_depth => true

  belongs_to :ownable, polymorphic: true

  belongs_to :variant
  belongs_to :account

  before_validation :process_variant

  validates_presence_of :variant_name, :unless => :variant_id?
  validates_presence_of :account, :unless => :cart? #, :unless => :order.account?
  validates_numericality_of :net_item
  validates_numericality_of :tax_item, :allow_nil => true
  validates_numericality_of :quantity

  def variant_id?
    variant_id
  end

  def cart?
    ownable_type == 'Cart'
  end

  def process_variant   # see below for more to be tested  - need to get description & price
    self.account_id = variant.item.item_type.account_id if variant_id.present? and quantity > 0
  end

  #def check_account
  #  self.account_id = params[:order][:account_id] if account_id.blank?
  #end

  #def process_variant
  #  if variant.present?
  #    self.net_item = ( variant.price.blank? ? variant.item.price : variant.price )
  #    self.net_item = ( variant.price.blank? ? variant.item.price : variant.price )
  #    self.desc = "#{variant.item.name}: #{variant.name}"
  #  else
  #    self.desc = variant_name
  #  end
  #  self.quantity = 1 if quantity.blank?
  #end

  #def ad_hoc?
  #  variant_id.blank?
  #end

  def order_account?
    order.account
  end

  def variant_name
    variant.try(:name)
  end

  def variant_name=(name)
    if ( variant = Variant.find_by_name(name) )
      self.variant = variant
      self.net_item = ( variant.price.blank? ? variant.item.price : variant.price )
      self.net_item = ( variant.price.blank? ? variant.item.price : variant.price )
      self.desc = "#{variant.item.name}: #{variant.name}"
    else
      self.variant_id = nil
      self.desc = variant_name
    end
  end

  fields =  Element.where( kind: 'item_choices')
  fields.each do |field|
    store_accessor :choices, field.name.downcase
  end


end
