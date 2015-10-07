class AddProjectIdToCodeNamespaces < ActiveRecord::Migration
  def change
    add_reference :code_namespaces, :project, index: true, foreign_key: true
  end
end
