class TableSerializer < ActiveModel::Serializer
  attributes :id, :number, :services

  def services
  	date = serialization_options[:date]
	services = Service.by_date(date).where(table_id: object.id)
    ActiveModel::ArraySerializer.new(services, each_serializer: ServiceSerializer).as_json
  end
end
