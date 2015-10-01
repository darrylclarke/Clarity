class CreateCodeClasses < ActiveRecord::Migration
  def change
    create_table :code_classes do |t|
      t.string :name
      t.string :ancestors
      t.references :code_file, index: true, foreign_key: true
      t.integer :line

      t.timestamps null: false
    end
  end
end
