class Ingredient < ActiveRecord::Base

  def cost
    cost_cents / 100.00 if cost_cents
  end
  def cost=(val)
    self.cost_cents = val ? val.to_d * 100.00 : 0
  end

  belongs_to :supplier
  belongs_to :unit, class_name: 'Element'
  belongs_to :quantity, class_name: 'Element'
  has_many :recipes, :dependent => :destroy

  validates :name, uniqueness: true, presence: true
  validates :quantity_id, presence: true
  validates :unit_id, presence: true

end
