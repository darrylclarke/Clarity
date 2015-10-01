class AddSpecifiedClassNameToCodeMethods < ActiveRecord::Migration
  def change
    add_column :code_methods, :specified_class_name, :string
  end
end
