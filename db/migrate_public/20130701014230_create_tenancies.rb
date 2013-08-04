class CreateTenancies < ActiveRecord::Migration
  def change
    create_table :tenancies do |t|
      t.string :name
      t.string :domain
      t.string :hostname

      t.timestamps
    end
  end
end
