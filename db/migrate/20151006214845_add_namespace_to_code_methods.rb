class AddNamespaceToCodeMethods < ActiveRecord::Migration
  def change
    add_reference :code_methods, :code_namespace, index: true, foreign_key: true
  end
end
