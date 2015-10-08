class AddNumLinesToCodeFiles < ActiveRecord::Migration
  def change
    add_column :code_files, :num_lines, :integer
  end
end
