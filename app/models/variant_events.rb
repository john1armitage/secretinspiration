class VariantEvents < ActiveRecord::Base
  belongs_to :variant
#  attr_accessible :state

  validates_presence_of :variant_id
  validates_inclusion_of :state, in: Variant::STATES

  before_save :set_user_id

  def set_user_id
    self.user_id = current_user.id
  end

  def self.with_last_state(state)
    variant("id desc").group("variant_id").having(state: state)
  end
end