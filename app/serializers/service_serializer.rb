class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :coordinator_id, :administrator_id, :client, :date, :table_id, :quantity, :ammount, :status, :organization, :coordinator_name, :seated_time, :completed_time
  has_one :table_number

  def table_number
  	object.table.number
  end

  	def coordinator_name
      object.coordinator.name
    end

end
