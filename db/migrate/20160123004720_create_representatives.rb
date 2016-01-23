class CreateRepresentatives < ActiveRecord::Migration
  def change
    create_table :representatives do |t|
      t.string :name, default: ""
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :representatives, :user_id
  end
end
