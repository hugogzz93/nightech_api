class ServicesController < ApplicationController
	respond_to :json

	def index
		date = DateTime.parse(params[:date])
		services = Service.by_date(date).where(organization: current_user.organization)
		if has_clearance?(current_user, 'administrator')
			render json: services, status: 200
		else
			head 403
		end		
	end

	def create
		service = current_user.build_service(service_params)
		service.organization = current_user.organization
		if authorized_for_service_creation(current_user) && service.save
			render json: service, status: 201, location: [ service]
		elsif !authorized_for_service_creation current_user
			head 403
		else
			render json: { errors: service.errors }, status: 422
		end
	end

	def update
		service = Service.find(params[:id])
		if cleared_for_update(current_user, service) && service.update(service_update_params)
			render json: service, status: 200, location: [ service]
		elsif !cleared_for_update(current_user, service)
			head 403
		else
			render json: { errors: service.errors }, status: 422
		end
	end

	def destroy
		service = Service.find(params[:id])
		if cleared_for_deletion(current_user, service)
			service.destroy
			head 204
		else
			head 403
		end
	end

	private

		def cleared_for_update(user, service)
			same_organization?(user, service) && authorized_for_service_update(user)
		end

		def cleared_for_deletion(user, service)
			same_organization?(user, service) && authorized_for_service_deletion(user, service)
		end

		def service_params
			params.require(:service).permit(:representative_id, :reservation_id, :client, :comment, :quantity, :ammount, :date, :status, :table_id)
		end

		def service_update_params
			params.require(:service).permit(:ammount, :status, :table_id, :date)
		end
	
end
