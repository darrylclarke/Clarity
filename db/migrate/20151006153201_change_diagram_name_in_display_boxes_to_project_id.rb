class ChangeDiagramNameInDisplayBoxesToProjectId < ActiveRecord::Migration
  def change
      rename_column :display_boxes, :diagram_name, :project_id
  end
end
