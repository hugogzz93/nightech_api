class AddUpdateTimeStampsToService < ActiveRecord::Migration
  def change
  	add_column :services, :seated_time, :datetime
  	add_column :services, :completed_time, :datetime
  end
end
