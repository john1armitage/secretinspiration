class Meal < ActiveRecord::Base

  belongs_to :seating
  belongs_to :tabel

  has_many :line_items, as: :ownable, dependent: :destroy

  def get_vat_rate(type)
    eval("CONFIG[:vat_rate_#{type}]")
  end

  def update_variant(variant_id, options, choices)
    p options
    p choices
    items = line_items.where(variant_id: variant_id)
    p items
    same_options = true
    current_item = nil
    items.each do |item|
      choices.each do |k, v|
        same_options = eval "item.#{k} == '#{v}'"
        p eval("item.#{k} == '#{v}'")
        p eval("item.#{k}")
      end
      current_item = item if same_options
    end
    p "SAME OPTIONS"
    p same_options
    p current_item
    if current_item
      add_variant(current_item)
    else
      current_item = create_variant(variant_id, options, choices)
    end
    current_item
  end

  def create_variant(variant_id, options, choices)
    variant = Variant.find(variant_id)
    current_item = line_items.build(variant_id: variant_id)
    current_item.desc = variant.item.name
    current_item.desc += ": #{variant.name} " unless variant.name == 'default'
    current_item.quantity = 1
    price = ( variant.price.to_d > 0 ? variant.price : variant.item.price )
    current_item.vat_rate = get_vat_rate( variant.item.vat_rate )
    type = variant.item.vat_rate
    current_item.net_item = price / ( 1 + current_item.vat_rate )
    current_item.tax_item = price - current_item.net_item
    calculate_totals(current_item)
    choices.each do |k, v|
      eval("current_item.#{k} = #{v}")
      p k
      p v
    end
    options.each do |k, v|
      p k
      p v
    end
    current_item
  end

  def calculate_totals(current_item)
    current_item.net_total_item = current_item.net_item * current_item.quantity
    current_item.tax_total_item = current_item.tax_item * current_item.quantity
  end

  def add_variant( current_item )
    current_item.quantity += 1
    calculate_totals(current_item)
    current_item
  end

  def subtract_variant(current_item)
    current_item.quantity -= 1
    if current_item.quantity == 0
      current_item.destroy
    else
      calculate_totals(current_item)
    end
    current_item
  end

end
