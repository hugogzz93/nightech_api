
class ReservationSerializer < ActiveModel::Serializer
  attributes :id, :client, :user_id, :representative_id, :quantity, :comment, :date, :status, :visible, :coordinator_name, :representative_name
  has_one :table_number

  	def table_number
  		object.service.table.number if object.service && (visible || serialization_options[:administrator])
  	end

  	def status
  		if object.service && object.service.status == "seated"
  			"seated"
  		else
  			object.status
  		end
  	end

    def coordinator_name
      object.user.name
    end

    def representative_name
      object.representative.name if object.representative
    end
end
