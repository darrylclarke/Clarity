class AddFolderReferenceToCodeFiles < ActiveRecord::Migration
  def change
    add_reference :code_files, :folder, index: true, foreign_key: true
  end
end
