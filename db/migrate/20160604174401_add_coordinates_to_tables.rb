class AddCoordinatesToTables < ActiveRecord::Migration
  def change
  	add_column :tables, :x, :integer, null: false, default: 0
  	add_column :tables, :y, :integer, null: false, default: 0
  end
end
