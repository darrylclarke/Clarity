class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name
      t.string :path

      t.timestamps null: false
    end
  end
end
