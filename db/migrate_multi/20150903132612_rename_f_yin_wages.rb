class RenameFYinWages < ActiveRecord::Migration
  def change
    remove_column :wages, :FY
    add_column :wages, :fy, :integer
  end
end
