class AddSurplusToDailies < ActiveRecord::Migration
  def change
    add_money :dailies, :surplus, currency: { present: false }
  end
end
