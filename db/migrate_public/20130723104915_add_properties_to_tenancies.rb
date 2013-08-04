class AddPropertiesToTenancies < ActiveRecord::Migration
  def change
    add_column :tenancies, :properties, :hstore
  end
end
