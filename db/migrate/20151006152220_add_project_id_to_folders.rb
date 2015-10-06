class AddProjectIdToFolders < ActiveRecord::Migration
  def change
    add_reference :folders, :project, index: true, foreign_key: true
  end
end
