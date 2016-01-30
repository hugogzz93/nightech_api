class ReservationSerializer < ActiveModel::Serializer
  attributes :id, :client, :user_id, :representative_id, :quantity, :comment, :date, :status, :visible
  has_one :table_number

  def table_number
  		if object.service && visible
  			object.service.table.number
  		else
  			
  		end
  	end
end
