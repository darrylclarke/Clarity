class AddNumCodeFilesToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :num_code_files, :integer
  end
end
