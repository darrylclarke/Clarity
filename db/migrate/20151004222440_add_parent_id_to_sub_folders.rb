class AddParentIdToSubFolders < ActiveRecord::Migration
  def change
    add_column :sub_folders, :parent_id, :integer
  end
end
