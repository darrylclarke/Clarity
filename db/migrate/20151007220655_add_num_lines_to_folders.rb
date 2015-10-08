class AddNumLinesToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :num_lines, :integer
  end
end
