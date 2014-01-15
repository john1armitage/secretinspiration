class AddBodiesToPages < ActiveRecord::Migration
  def change
    add_column :pages, :body2, :text
    add_column :pages, :body3, :text
  end
end
