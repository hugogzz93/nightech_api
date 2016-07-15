class TableSerializer < ActiveModel::Serializer
  attributes :id, :number, :services, :x, :y

  def services
  	date = serialization_options[:date]
	services = Service.by_date(date, "day").where(table_id: object.id)
    ActiveModel::ArraySerializer.new(services, each_serializer: ServiceSerializer).as_json
  end
end
