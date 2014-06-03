class CreateMessage < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message
      t.belongs_to :user, index: true
      t.string :message_type

      t.timestamps
    end
  end
end
