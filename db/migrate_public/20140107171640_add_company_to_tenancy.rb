class AddCompanyToTenancy < ActiveRecord::Migration
  def change
    add_column :tenancies, :company, :string
    add_column :tenancies, :coho, :string
    add_column :tenancies, :vat, :string
  end
end
