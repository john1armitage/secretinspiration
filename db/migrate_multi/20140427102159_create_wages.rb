class CreateWages < ActiveRecord::Migration
  def change
    create_table :wages do |t|
      t.integer :FY
      t.integer :week_no
      t.belongs_to :employee, index: true
      t.decimal :hours, :precision => 4, :scale => 2
      t.money :rate, currency: { present: false }
      t.money :gross, currency: { present: false }
      t.money :NI_employer, currency: { present: false }
      t.money :NI_employee, currency: { present: false }
      t.money :PAYE, currency: { present: false }
      t.money :tips, currency: { present: false }
      t.date :paid_date

      t.timestamps
    end
  end
end

