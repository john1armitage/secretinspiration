class AddCapacityToTenancies < ActiveRecord::Migration
  def change
    add_column :tenancies, :capacity, :integer
  end
end
