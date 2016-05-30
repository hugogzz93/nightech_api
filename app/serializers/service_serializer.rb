class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :coordinator_id, :administrator_id, :client, :date, :quantity, :ammount, :status, :organization
  has_one :table_number

  def table_number
  	object.table.number
  end
end
