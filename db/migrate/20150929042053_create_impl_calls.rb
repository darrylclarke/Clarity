class CreateImplCalls < ActiveRecord::Migration
  def change
    create_table :impl_calls do |t|
      t.integer :caller_id
      t.integer :called_id
      t.string :external_call
      t.integer :line

      t.timestamps null: false
    end
  end
end
