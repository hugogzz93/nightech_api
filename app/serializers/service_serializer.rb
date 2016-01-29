class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :administrator_id, :date, :quantity, :ammount, :status,
end
