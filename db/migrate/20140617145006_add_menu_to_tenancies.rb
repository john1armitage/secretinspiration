class AddMenuToTenancies < ActiveRecord::Migration
  def change
    add_column :tenancies, :menu, :string
  end
end
