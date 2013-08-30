class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :ni_number
      t.money :hourly_rate
      t.string :address1
      t.string :address2
      t.string :town
      t.string :postcode
      t.string :mobile_phone
      t.string :home_phone
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
