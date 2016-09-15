class AddMapStringToOrganizations < ActiveRecord::Migration
  def change
  	add_column :organizations, :map, :string, null: false, default: "M 0,0"
  end
end
