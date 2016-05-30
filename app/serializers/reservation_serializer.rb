class ReservationSerializer < ActiveModel::Serializer
  attributes :id, :client, :user_id, :representative_id, :quantity, :comment, :date, :status, :visible
  has_one :table_number

  	def table_number
  		object.service.table.number if object.service && visible
  	end

  	def status
  		if object.service && object.service.status == "seated"
  			"seated"
  		else
  			object.status
  		end
  	end
end
