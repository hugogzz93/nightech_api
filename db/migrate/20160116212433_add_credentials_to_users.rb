class AddCredentialsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :credentials, :integer, default: 0
  end
end
