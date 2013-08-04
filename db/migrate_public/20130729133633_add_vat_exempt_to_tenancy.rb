class AddVatExemptToTenancy < ActiveRecord::Migration
  def change
    add_column :tenancies, :vat_exempt, :boolean, default: false
  end
end
