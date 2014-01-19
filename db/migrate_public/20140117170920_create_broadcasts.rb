class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
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
    add_column :broadcasts, :color, :string
    add_column :broadcasts, :image, :string
    add_column :broadcasts, :body2, :text
    add_column :broadcasts, :body3, :text
    add_column :broadcasts, :link, :string
    add_column :broadcasts, :link2, :string
    add_column :broadcasts, :link3, :string
  end
end
