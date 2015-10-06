class CreateDisplayBoxLines < ActiveRecord::Migration
  def change
    create_table :display_box_lines do |t|
      t.references :display_box, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
