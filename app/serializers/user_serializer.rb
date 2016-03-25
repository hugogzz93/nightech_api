class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :updated_at, :auth_token, :supervisor_id, :credentials, :name
  has_many :coordinated_services, :administered_services, :reservations
end
