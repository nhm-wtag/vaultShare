class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.string :action, null: false
      t.references :user, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.timestamps
    end
    add_index :activity_logs, :created_at
  end
end
