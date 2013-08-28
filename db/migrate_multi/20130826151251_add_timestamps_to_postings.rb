class AddTimestampsToPostings < ActiveRecord::Migration
  def change
    add_timestamps :postings
  end
end
