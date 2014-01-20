class AddFeaturesToPages < ActiveRecord::Migration
  def change
    add_column :pages, :feature2, :string
    add_column :pages, :feature3, :string
  end
end
