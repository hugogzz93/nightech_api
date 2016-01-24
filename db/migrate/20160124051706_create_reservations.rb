class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.string :client, null: false
      t.integer :user_id, null: false
      t.integer :representative_id
      t.integer :quantity, default: 1
      t.string :comment, default: ""
      t.datetime :date, null: false
      t.integer :status, default: 0
      t.boolean :visible, default: false

      t.timestamps null: false
    end
  end
end
