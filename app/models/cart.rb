class Cart < ActiveRecord::Base

  has_many :line_items, as: :ownable, dependent: :destroy

  belongs_to :user

  def update_variant(variant_id)
    current_item = line_items.find_by(variant_id: variant_id)
    if current_item
      add_variant(current_item)
    else
      current_item = create_variant(variant_id)
    end
    current_item
  end

  def create_variant(variant_id)
    current_item = line_items.build(variant_id: variant_id)
  end

  def add_variant( current_item )
    current_item.quantity += 1
    current_item
  end

  def subtract_variant(current_item)
    current_item.quantity -= 1
    if current_item.quantity == 0
      current_item.destroy
      nil
    else
      current_item
    end
  end

end
