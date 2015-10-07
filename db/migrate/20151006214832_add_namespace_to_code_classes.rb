class AddNamespaceToCodeClasses < ActiveRecord::Migration
  def change
    add_reference :code_classes, :code_namespace, index: true, foreign_key: true
  end
end
