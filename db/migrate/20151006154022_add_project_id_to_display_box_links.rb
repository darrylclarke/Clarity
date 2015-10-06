class AddProjectIdToDisplayBoxLinks < ActiveRecord::Migration
  def change
    add_column :display_box_links, :project_id, :integer
  end
end
