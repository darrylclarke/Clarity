class RenamePercentColumnInDisplayBoxes < ActiveRecord::Migration
  def change
    rename_column :display_boxes, :percent_of_total, :num_code_files
  end
end
