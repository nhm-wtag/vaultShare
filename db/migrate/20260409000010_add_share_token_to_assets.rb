class AddShareTokenToAssets < ActiveRecord::Migration[8.1]
  def change
    add_column :assets, :share_token, :string
    add_column :assets, :share_token_expires_at, :datetime
    add_index :assets, :share_token, unique: true
  end
end
