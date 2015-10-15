class Item < ActiveRecord::Base

  # monetize :price_cents, :allow_nil => true

  def price
    price_cents / 100.00 if price_cents
  end

  def price=(val)
    self.price_cents = val ? val.to_d * 100.00 : 0
  end

  def cost
    cost_cents / 100.00 if cost_cents
  end
  def cost=(val)
    self.cost_cents = val ? val.to_d * 100.00 : 0
  end

  has_many :variants #, :dependent => :destroy
  has_many :stocks, :dependent => :destroy

  belongs_to :item_type
  belongs_to :category
  has_many :supplies
  has_many :suppliers, through: :supplies
  has_many :recipes, :dependent => :destroy

  acts_as_taggable

  before_save :generate_slug

  validates_presence_of :name
  validates_presence_of :category
  validates_numericality_of :price, :allow_nil => true

  attr_accessor :domain, :vat_exempt

  after_create :create_default_variant
  before_save :set_grouping_plus

  def sups
    supplies.map {|o| o.supplier_id}
  end

  def set_grouping_plus
    if category.name == 'vegetarian_starter'
      starter = Category.find_by_name('starter')
      self.grouping = "#{starter.rank}:#{starter.name}"
    elsif category.name == 'vegetarian_mains'
      main = Category.find_by_name('main')
      self.grouping = "#{main.rank}:#{main.name}"
    elsif category.name == 'child_dessert'
      dessert = Category.find_by_name('dessert')
      self.grouping = "#{dessert.rank}:#{dessert.name}"
    else
      self.grouping = "#{category.parent.rank}:#{category.parent.name}"
    end
    self.item_type = ItemType.find_by_name( category.parent.name )
    self.vat_rate = item_type.vat_rate if vat_rate.blank? and !vat_exempt
  end

  def create_default_variant
    variant = variants.create(name: 'default', domain: domain, item_default: true, withdrawn: false)
  end

  def item_type_name
    item_type.name
  end

  def desc
    description[0..20]
  end

  def generate_slug
    if  slug.blank?
      slug = "#{category.name.gsub(/_/,'-')}-#{name}"
      self.slug = slug.parameterize
    end

  end

  def to_param
    slug
  end

  def self.latest
    Item.order(:updated_at).last
  end

end
