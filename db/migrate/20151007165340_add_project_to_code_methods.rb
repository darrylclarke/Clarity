class AddProjectToCodeMethods < ActiveRecord::Migration
  def change
    add_reference :code_methods, :project, index: true, foreign_key: true
  end
end
