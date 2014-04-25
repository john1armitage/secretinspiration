class AddDomainsToElements < ActiveRecord::Migration
  def change
    add_column :elements, :properties, :hstore
  end
end
