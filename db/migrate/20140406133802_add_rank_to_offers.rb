class AddRankToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :rank, :integer
  end
end
