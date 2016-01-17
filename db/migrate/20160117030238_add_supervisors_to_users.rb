class AddSupervisorsToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :supervisor, index: true, foreign_key: true
  end
end
