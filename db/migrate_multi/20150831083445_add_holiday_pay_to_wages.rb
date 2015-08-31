class AddHolidayPayToWages < ActiveRecord::Migration
  def change
    add_column :wages, :holiday_cents, :integer
    add_column :wages, :bonus_cents, :integer
  end
end
