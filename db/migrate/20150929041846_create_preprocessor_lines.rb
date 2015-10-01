class CreatePreprocessorLines < ActiveRecord::Migration
  def change
    create_table :preprocessor_lines do |t|
      t.string :text
      t.references :code_file, index: true, foreign_key: true
      t.integer :line

      t.timestamps null: false
    end
  end
end
