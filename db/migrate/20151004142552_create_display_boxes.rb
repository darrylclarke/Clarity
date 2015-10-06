class CreateDisplayBoxes < ActiveRecord::Migration
  def change
    create_table :display_boxes do |t|
      t.string :diagram_name
      t.string :text
      t.integer :x_pos
      t.integer :y_pos
      t.integer :height
      t.integer :width
      t.references :folder, index: true, foreign_key: true
      t.references :code_class, index: true, foreign_key: true
      t.integer :percent_of_total
      t.integer :notes_flags

      t.timestamps null: false
    end
  end
end
