class AddSlugToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :slug, :string
    add_index :variants, :slug
  end
end
