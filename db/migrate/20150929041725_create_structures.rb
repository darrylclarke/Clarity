class CreateStructures < ActiveRecord::Migration
  def change
    create_table :structures do |t|
      t.string :name
      t.string :type_of
      t.references :code_file, index: true, foreign_key: true
      t.integer :line

      t.timestamps null: false
    end
  end
end
