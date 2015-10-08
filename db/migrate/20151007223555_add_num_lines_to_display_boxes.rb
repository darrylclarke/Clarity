class AddNumLinesToDisplayBoxes < ActiveRecord::Migration
  def change
    add_column :display_boxes, :num_lines, :integer
  end
end
