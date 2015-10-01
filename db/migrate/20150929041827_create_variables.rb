class CreateVariables < ActiveRecord::Migration
  def change
    create_table :variables do |t|
      t.string :name
      t.string :type
      t.references :code_file, index: true, foreign_key: true
      t.references :code_class, index: true, foreign_key: true
      t.integer :line

      t.timestamps null: false
    end
  end
end
