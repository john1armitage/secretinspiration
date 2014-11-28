class AddGroupingToPostings < ActiveRecord::Migration
  def change
    add_column :postings, :grouping, :integer
  end
end
