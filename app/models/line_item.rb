class LineItem < ActiveRecord::Base

  # monetize :net_item_cents, :allow_nil => true
  # monetize :tax_item_cents, :allow_nil => true
  # monetize :net_home_cents, :allow_nil => true
  # monetize :tax_home_cents, :allow_nil => true
  # monetize :net_total_item_cents, :allow_nil => true
  # monetize :tax_total_item_cents, :allow_nil => true
  # monetize :discount_cents, :allow_nil => true
  #

  def net_total_item
    net_total_item_cents / 100.00 if net_total_item_cents
  end
  def net_total_item=(val)
    self.net_total_item_cents = val ? val.to_d * 100 : 0
  end

  def tax_total_item
    tax_total_item_cents / 100.00 if tax_total_item_cents
  end
  def tax_total_item=(val)
    self.tax_total_item_cents = val ? val.to_d * 100 : 0
  end

  def net_item
    net_item_cents / 100.00 if net_item_cents
  end
  def net_item=(val)
    self.net_item_cents = val ? val.to_d * 100 : 0
  end

  def tax_item
    tax_item_cents / 100.00 if tax_item_cents
  end
  def tax_item=(val)
    self.tax_item_cents = val ? val.to_d * 100 : 0
  end

  def net_home_item
    net_home_cents / 100.00 if net_home_cents
  end
  def net_home=(val)
    self.net_home_cents = val ? val.to_d * 100 : 0
  end

  def tax_home
    tax_home_cents / 100.00 if tax_home_cents
  end
  def tax_home=(val)
    self.tax_home_cents = val ? val.to_d * 100 : 0
  end

  def discount
    discount_cents / 100.00 if discount_cents
  end
  def discount=(val)
    self.discount_cents = val ? val.to_d * 100 : 0
  end


  has_ancestry :cache_depth => true, :orphan_strategy => :destroy

  has_one  :posting, as: :postable, dependent: :destroy

  belongs_to :ownable, polymorphic: true

  belongs_to :variant
  belongs_to :option
  belongs_to :account

  before_validation :process_variant unless :special?
  before_validation :process_home
  #
  validates_presence_of :desc, unless: :special?
  validates_presence_of :account, unless: :special? #, :unless => :cart_or_blank?
  validates_numericality_of :net_item, :greater_than => 0, :message => 'is required', unless: :special? #, :allow_nil => true
  validates_numericality_of :tax_item, :allow_nil => true, unless: :special?
  validates_numericality_of :quantity, unless: :special?

  fields =  Element.where( kind: 'item_choices')
  fields.each do |field|
    store_accessor :choices, field.name.downcase
  end
  def special?
    !special.blank? ||  variant_id || option_id
  end


  def process_home
    unless exchange_rate.blank?
      self.net_home_cents = net_total_item_cents / exchange_rate
      self.tax_home_cents = tax_total_item_cents / exchange_rate
    end
  end

  def process_variant
    self.account_id = variant.item.item_type.account_id if variant_id.present?
    self.quantity = 1 unless quantity.to_i > 0
  end

  # def linked_id?
  #   variant_id || option_id
  # end

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
