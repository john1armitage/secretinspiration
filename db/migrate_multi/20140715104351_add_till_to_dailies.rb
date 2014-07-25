class AddTillToDailies < ActiveRecord::Migration
  def change
    add_money :dailies, :till, currency: { present: false }
  end
end
