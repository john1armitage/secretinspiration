class Timing < ActiveRecord::Base

  belongs_to :timeable, polymorphic: true

end
