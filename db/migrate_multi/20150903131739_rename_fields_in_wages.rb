class RenameFieldsInWages < ActiveRecord::Migration
  def change
    remove_column :wages, :PAYE_cents
    add_column :wages, :paye_cents, :integer, default: 0
    remove_column :wages, :NI_employee_cents
    add_column :wages, :ni_employee_cents, :integer, default: 0
    remove_column :wages, :NI_employer_cents
    add_column :wages, :ni_employer_cents, :integer, default: 0
  end
end
