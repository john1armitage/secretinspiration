class AddFYtoDailies < ActiveRecord::Migration
  def change
    add_column :dailies, :FY, :integer
    add_column :dailies, :week_no, :integer
  end
end
