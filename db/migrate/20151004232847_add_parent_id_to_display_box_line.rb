class AddParentIdToDisplayBoxLine < ActiveRecord::Migration
  def change
    add_column :display_box_lines, :parent_id, :integer
  end
end
