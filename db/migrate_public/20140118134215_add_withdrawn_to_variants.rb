class AddWithdrawnToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :withdrawn, :boolean
  end
end
