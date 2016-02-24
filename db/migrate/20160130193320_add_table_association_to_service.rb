class AddTableAssociationToService < ActiveRecord::Migration
  def change
  	add_column :services, :table_id, :integer, null: false, default: 1
  	add_index :services, :table_id

    Service.reset_column_information
 
    Service.all.each do |account|
      service.table_id = 1
      service.save!
    end
 
    change_column :services, :table_id, :integer, null: false, default: null
  end
end
