class AddLinksToPages < ActiveRecord::Migration
  def change
    add_column :pages, :link, :string
    add_column :pages, :link2, :string
    add_column :pages, :link3, :string
  end
end
