class AddAccountIdToPostings < ActiveRecord::Migration
  def change
    add_reference :postings, :account, index: true
  end
end
