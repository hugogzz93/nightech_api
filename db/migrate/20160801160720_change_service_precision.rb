class ChangeServicePrecision < ActiveRecord::Migration
  def change
  	change_column :services, :ammount, :decimal, :precision => 9, :scale => 2
  end
end
