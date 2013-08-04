class AddRankToOptions < ActiveRecord::Migration
  def change
    add_column :options, :rank, :integer
  end
end
