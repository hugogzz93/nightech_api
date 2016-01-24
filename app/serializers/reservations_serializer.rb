class ReservationsSerializer < ActiveModel::Serializer
  attributes :id, :client, :user_id, :representative_id, :quantity, :comment, :date, :status, :visible
end
