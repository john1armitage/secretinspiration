class AddDefaultCategoryToTenancies < ActiveRecord::Migration
  def change
    add_column :tenancies, :default_category, :string
  end
end
