class CreateDisplayBoxLinks < ActiveRecord::Migration
  def change
    create_table :display_box_links do |t|
      t.integer :from
      t.integer :to

      t.timestamps null: false
    end
  end
end
