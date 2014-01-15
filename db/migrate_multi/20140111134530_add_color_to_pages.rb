class AddColorToPages < ActiveRecord::Migration
  def change
    add_column :pages, :color, :string
  end
end
