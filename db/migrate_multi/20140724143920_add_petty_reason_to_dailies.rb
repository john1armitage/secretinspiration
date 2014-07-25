class AddPettyReasonToDailies < ActiveRecord::Migration
  def change
    add_column :dailies, :petty_reason, :string
  end
end
