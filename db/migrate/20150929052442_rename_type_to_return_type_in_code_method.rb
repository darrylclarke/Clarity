class RenameTypeToReturnTypeInCodeMethod < ActiveRecord::Migration
  def change
    rename_column :code_methods, :type, :return_type
  end
end
