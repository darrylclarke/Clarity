class AddProjectToCodeClasses < ActiveRecord::Migration
  def change
    add_reference :code_classes, :project, index: true, foreign_key: true
  end
end
