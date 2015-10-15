class Ingredient < ActiveRecord::Base

  belongs_to :supplier
  has_many :recipes

end
