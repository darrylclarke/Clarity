class AddSignatureLineToCodeMethods < ActiveRecord::Migration
  def change
    add_column :code_methods, :signature_line, :integer
  end
end
