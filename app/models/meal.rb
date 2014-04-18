class Meal < ActiveRecord::Base

  belongs_to :seating
  belongs_to :tabel

  has_many :line_items, as: :ownable, dependent: :destroy

  validates_presence_of :contact, :phone, :start_time,  if: :remote_takeaway?
  validates  :contact,  length: { minimum: 2, too_short: 'too short' },   if: :remote_takeaway?
  validates  :phone,  length: { minimum: 6, too_short: 'number too short' },  if: :remote_takeaway?

  def remote_takeaway?
    state == 'takeaway' and seating_id.blank? and line_items
  end

  def get_vat_rate(type)
    eval("CONFIG[:vat_rate_#{type}]")  || 0
  end

  def update_variant(variant_id, options, choices)
    items = line_items.where(variant_id: variant_id)
    same_choices = true
    current_item = nil
    items.each do |item|
      choices.each do |k, v|
        same_choices = eval "item.#{k} == '#{v}'"
        #p eval("item.#{k} == '#{v}'")
        #p eval("item.#{k}")
      end
      if same_choices
        current_item = item
      end
    end
    inline_options = []
    line_item_options = []
    options.each do |k, option_set|
      option_set.each do |o|
        inline_options << o
        #option = Element.find_by_name(o)
        #if option.price.to_d > 0
        #  line_item_options << option
        #else
        #  inline_options << option.name
        #end
      end
    end
    inline_options = inline_options.join(', ')
    if current_item && current_item.options == inline_options
      add_variant(current_item)
    else
      current_item = create_variant(variant_id, inline_options, choices)
    end
    line_item_options.each do |option|
      current_option_item = current_item.children.find_by_option_id(option.id) unless current_item.new_record?
      if current_option_item
        current_option_item.quantity += 1
        calculate_option_totals(current_option_item)
        current_option_item.save
      else
        current_item.save
        create_option_child(current_item, option)
      end
    end
    current_item
  end

  def create_option_child (current_item, option)
    option_child = current_item.children.create(option_id: option.id, desc: option.name, quantity: 1)

    price = option.price
    option_child.vat_rate = get_vat_rate( option.vat_rate )
    option_child.net_item = price / ( 1 + option_child.vat_rate )
    option_child.tax_item = price - option_child.net_item
    calculate_option_totals(option_child)
    option_child.account = current_item.account
    option_child.save
  end

  # line_item[ownable_id]:186
  # line_item[ownable_type]:Meal
  # line_item[special]:main
  # line_item[desc]:hhhh
  # each:6
  #
  # line_item[quantity]:1


  def create_special(variant_id, item_price, params_line_item)
    variant = Variant.find(variant_id)
    variant.price = item_price.to_d / params_line_item[:quantity].to_d
    current_item = line_items.build(variant_id: variant_id)
    price = variant.price
    current_item.vat_rate = get_vat_rate( variant.item.vat_rate )
    current_item.account_id = ItemType.find_by_name(variant.item.category.parent.name).account_id
    current_item.net_item = price / ( 1 + current_item.vat_rate )
    current_item.tax_item = price - current_item.net_item
    current_item.quantity = params_line_item[:quantity]
    calculate_totals(current_item)
    current_item.ownable_id = params_line_item[:ownable_id]
    current_item.ownable_type = 'Meal'
    current_item.desc = params_line_item[:desc]
    current_item.special = params_line_item[:special]
    current_item
  end

  def create_variant(variant_id,  inline_options, choices)
    variant = Variant.find(variant_id)
    current_item = line_items.build(variant_id: variant_id)
    current_item.desc = variant.item.name
    current_item.desc += ": #{variant.name} " unless variant.name == 'default'
    current_item.quantity = 1
    price = ( variant.price.to_d > 0 ? variant.price : variant.item.price )
    current_item.account_id = ItemType.find_by_name(variant.item.category.parent.name).account_id
    current_item.vat_rate = get_vat_rate( variant.item.vat_rate )
    current_item.net_item = price / ( 1 + current_item.vat_rate )
    current_item.tax_item = price - current_item.net_item
    calculate_totals(current_item)
    current_item.options = inline_options
    choices.each do |k, v|
      eval("current_item.#{k} = #{v}")
    end
    current_item
  end

  def calculate_option_totals(option_child)
    option_child.net_total_item = option_child.net_item * option_child.quantity
    option_child.tax_total_item = option_child.tax_item * option_child.quantity
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

  def add_option( current_item )
    current_item.quantity += 1
    calculate_totals(current_item)
    current_item
  end

  def subtract_option(current_item)
    current_item.quantity -= 1
    if current_item.quantity == 0
      if current_item.is_only_child?  && ( current_item.parent.net_item_cents == 0 )
        current_item.parent.destroy
      else
        current_item.destroy
      end
    else
      calculate_totals(current_item)
    end
    current_item
  end


end
