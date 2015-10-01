class CreateCodeFiles < ActiveRecord::Migration
  def change
    create_table :code_files do |t|
      t.string :name
      t.string :path
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
