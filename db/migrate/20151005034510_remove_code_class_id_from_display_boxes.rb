class RemoveCodeClassIdFromDisplayBoxes < ActiveRecord::Migration
  def change
  remove_column :display_boxes, :code_class_id
  end
end
