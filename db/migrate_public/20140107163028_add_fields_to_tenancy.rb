class AddFieldsToTenancy < ActiveRecord::Migration
  def change
    add_column :tenancies, :email, :string
    add_column :tenancies, :address, :string
    add_column :tenancies, :phone, :string
  end
end
