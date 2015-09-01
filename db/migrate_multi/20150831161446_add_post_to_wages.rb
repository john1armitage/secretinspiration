class AddPostToWages < ActiveRecord::Migration
  def change
    add_column :wages, :post, :boolean, default: true
  end
end
