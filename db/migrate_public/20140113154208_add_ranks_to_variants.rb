class AddRanksToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :rank, :integer
  end
end
