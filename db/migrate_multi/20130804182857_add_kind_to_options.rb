class AddKindToOptions < ActiveRecord::Migration
  def change
    add_column :options, :kind, :string
  end
end
