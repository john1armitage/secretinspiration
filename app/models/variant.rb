class Variant < ActiveRecord::Base

  monetize :price_cents, :allow_nil => true

  belongs_to :item

  has_many :pics, as: :viewable
  has_many :events, class_name: "VariantEvents"

  has_many :line_items

  before_validation :generate_slug

  validates_presence_of :name
  validates :slug, uniqueness: true, presence: true
  validates_numericality_of :price, :allow_nil => true

  before_destroy :ensure_not_referenced_by_any_line_item

  acts_as_taggable

  #default_scope where( :domain => current_tenant.domain)

  def ensure_not_referenced_by_any_line_item
    if line_items.empty?
      return true
    else
      errors.add(:base, 'Variant used in Line Items')
      return false
    end
  end

  def item_name
    item.name
  end

  def description
    desc[0..20]
  end

  def generate_slug
    if  self.slug.blank?
      slug = "#{item_name}-#{name}"
      self.slug = slug.parameterize
    end
  end


  def to_param
    slug
  end

  fields =  ItemField.all

  fields.each do |field|
    if field.options == true
      store_accessor :options, field.name.downcase
    else
      store_accessor :properties, field.name.downcase
    end
  end
  #fields.each do |field|
  #end

  def self.latest
    Variant.order(:updated_at).last
  end

  STATES = %w[incomplete open canceled shipped]
  delegate :incomplete?, :open?, :cancelled?, :shipped?, to: :current_state

  def self.open_orders
    joins(:events).merge OrderEvent.with_last_state("open")
  end

  def current_state
    (events.last.try(:state) || STATES.first).inquiry
  end

  def purchase(valid_payment = true)
    if incomplete?
      # process purchase ...
      events.create! state: "open" if valid_payment
    end
  end

  def cancel
    events.create! state: "cancelled" if open?
  end

  def resume
    events.create! state: "open" if canceled?
  end

  def ship
    events.create! state: "shipped" if open?
  end

end
