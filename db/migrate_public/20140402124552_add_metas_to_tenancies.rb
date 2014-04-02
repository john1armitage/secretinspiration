class AddMetasToTenancies < ActiveRecord::Migration
  def change
    add_column :tenancies, :title, :string
    add_column :tenancies, :description, :text
    add_column :tenancies, :keywords, :text
  end
end
