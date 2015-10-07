class CreateCodeNamespaces < ActiveRecord::Migration
  def change
    create_table :code_namespaces do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
