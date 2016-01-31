class Api::V1::ServicesController < ApplicationController
	respond_to :json

	def index
		date = DateTime.parse(params[:date])
		services = Service.by_date(date)
		if has_clearance?(current_user, "administrator")
			render json: services, status: 200
		else
			head 403
		end		
	end

	def create
		service = current_user.build_service(service_params)
		if authorized_for_service_creation(current_user) && service.save
			render json: service, status: 201, location: [:api, service]
		else
			if !authorized_for_service_creation current_user
				head 403
			else
				render json: { errors: service.errors }, status: 422
			end
		end
	end

	def service_params
		params.require(:service).permit(:representative_id, :reservation_id, :client, :comment, :quantity, :ammount, :date, :status, :table_id)
	end

	def service_update_params
		params.require(:service).permit(:ammount, :status, :table_id)
	end
	
end
