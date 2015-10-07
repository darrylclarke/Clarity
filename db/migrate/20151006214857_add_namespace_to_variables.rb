class AddNamespaceToVariables < ActiveRecord::Migration
  def change
    add_reference :variables, :code_namespace, index: true, foreign_key: true
  end
end
