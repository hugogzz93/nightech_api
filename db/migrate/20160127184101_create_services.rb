class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :user_id, null: false
      t.integer :administrator_id, null: false
      t.integer :representative_id
      t.integer :reservation_id
      t.string :client, null: false
      t.string :comment, default: ""
      t.integer :quantity, default: 1, null: false
      t.decimal :ammount, precision: 7, scale: 2
      t.timestamp :date, null: false
      t.integer :status, default: 0

      t.timestamps null: false
    end
  end
end
