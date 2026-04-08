class CreateLibraries < ActiveRecord::Migration[8.1]
  def change
    create_table :libraries do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :visibility, default: 0, null: false
      t.timestamps
    end
    add_index :libraries, [:user_id, :name]
  end
end
