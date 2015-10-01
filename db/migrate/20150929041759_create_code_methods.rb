class CreateCodeMethods < ActiveRecord::Migration
  def change
    create_table :code_methods do |t|
      t.string :name
      t.string :type
      t.string :arguments
      t.references :code_file, index: true, foreign_key: true
      t.references :code_class, index: true, foreign_key: true
      t.integer :impl_start
      t.integer :impl_end

      t.timestamps null: false
    end
  end
end
