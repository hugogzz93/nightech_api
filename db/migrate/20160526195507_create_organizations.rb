class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.boolean :active
    end

    add_reference :users, 			:organization, index: true, foreign_key: true
    add_reference :reservations, 	:organization, index: true, foreign_key: true
    add_reference :services, 		:organization, index: true, foreign_key: true
    add_reference :representatives, :organization, index: true, foreign_key: true
    add_reference :tables, 			:organization, index: true, foreign_key: true


  end
end
