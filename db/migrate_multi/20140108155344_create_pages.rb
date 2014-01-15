class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :code
      t.string :title
      t.string :sub
      t.text :body
      t.belongs_to :topic, index: true
      t.belongs_to :user
      t.string :credit
      t.boolean :publish
      t.date :release

      t.timestamps
    end
  end
end
