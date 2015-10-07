class AddProjectToVariables < ActiveRecord::Migration
  def change
    add_reference :variables, :project, index: true, foreign_key: true
  end
end
