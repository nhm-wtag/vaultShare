class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.string :title, null: false
      t.text :description
      t.string :file_type
      t.bigint :file_size
      t.references :collection, null: false, foreign_key: true
      t.timestamps
    end
  end
end
