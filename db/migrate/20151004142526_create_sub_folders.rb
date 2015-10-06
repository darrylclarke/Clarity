class CreateSubFolders < ActiveRecord::Migration
  def change
    create_table :sub_folders do |t|
      t.references :folder, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
