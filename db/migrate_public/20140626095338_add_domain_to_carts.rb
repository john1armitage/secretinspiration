class AddDomainToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :domain, :string
  end
end
