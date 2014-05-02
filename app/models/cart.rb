class Cart < ActiveRecord::Base

  has_many :line_items, as: :ownable, dependent: :destroy

  belongs_to :user

  def update_variant(variant_id)
    current_item = line_items.where(variant_id: variant_id).first
    if current_item
      add_variant(current_item)
    else
      current_item = create_variant(variant_id)
    end
    current_item
  end

  def create_variant(variant_id, quantity = 1, currency = 'GBP')
    variant = Variant.find(variant_id)

    current_item = line_items.build( variant: variant )
    current_item.desc = variant.item.name
    current_item.desc += ": #{variant.name} " unless variant.name == 'default'

    current_item.quantity = quantity
    price = ( variant.price_cents.to_d > 0 ? variant.price : variant.item.price )
    current_item.vat_rate = get_vat_rate( variant.item.vat_rate )
    current_item.net_item = price / ( 1 + current_item.vat_rate )
    current_item.tax_item = price - current_item.net_item
    current_item.net_item_currency = currency
    calculate_totals(current_item)

    current_item
  end

  def add_variant( current_item )
    unless current_item.variant.item.unique
      current_item.quantity += 1
      calculate_totals(current_item)
    end
    current_item
  end

  def subtract_variant(current_item)
    current_item.quantity -= 1
    if current_item.quantity == 0
      current_item.destroy
      nil
    else
      calculate_totals(current_item)
      current_item
    end
  end

  def get_vat_rate(type)
    eval("CONFIG[:vat_rate_#{type}]") || 0
  end

  def calculate_totals(current_item)
    current_item.net_total_item = current_item.net_item * current_item.quantity
    current_item.tax_total_item = current_item.tax_item * current_item.quantity
  end

end
