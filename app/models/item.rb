class Item < ActiveRecord::Base

  monetize :price_cents, :allow_nil => true

  has_many :variants, :dependent => :destroy

  belongs_to :item_type
  belongs_to :category

  acts_as_taggable

  before_save :generate_slug

  validates_presence_of :name
  validates_presence_of :category
  validates_numericality_of :price, :allow_nil => true

  attr_accessor :domain, :vat_exempt

  before_create :create_default_variant
  before_save :set_grouping_plus

  def set_grouping_plus
    self.grouping = "#{category.parent.rank}:#{category.parent.name}"
    self.item_type = ItemType.find_by_name( category.parent.name )
    self.vat_rate = item_type.vat_rate if vat_rate.blank? and !vat_exempt
  end

  def create_default_variant
    variant = variants.build(name: 'default', domain: domain, item_default: true)
  end

  def item_type_name
    item_type.name
  end

  def description
    desc[0..20]
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
