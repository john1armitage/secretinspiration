class AddRankToBanks < ActiveRecord::Migration
  def change
    add_column :banks, :rank, :integer
  end
end
