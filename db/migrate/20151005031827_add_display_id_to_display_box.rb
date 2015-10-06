class AddDisplayIdToDisplayBox < ActiveRecord::Migration
  def change
    add_column :display_boxes, :display_id, :integer
  end
end
