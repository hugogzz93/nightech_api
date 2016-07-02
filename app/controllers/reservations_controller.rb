class ReservationsController < ApplicationController
	respond_to :json
	
	def index
		date = DateTime.parse(params[:date])
		reservations = Reservation.by_date(date)
		if has_clearance?(current_user, 'administrator')
			render json: reservations.where(organization: current_user.organization), status: 200
		else
			render json: reservations.where(user_id: current_user.id), status: 200
		end
	end

	def create
		reservation = current_user.reservations.build(reservation_params)
		reservation.organization = current_user.organization
		if reservation.save
			render json: reservation, status: 201, location: [ reservation]
		else
			render json: { errors: reservation.errors }, status: 422
		end
	end

	def update
		reservation = Reservation.find(params[:id])
		if cleared_for_update(current_user, reservation) && reservation.update(reservation_update_params)
			if reservation_update_params["status"] == "accepted"
				handle_reservation_acceptance reservation
			else
				render json: reservation, status: 200, location: [ reservation]
			end
		elsif !cleared_for_update(current_user, reservation)
			head 403
		else
			render json: { errors: reservation.errors }, status: 422
		end
	end

	def destroy
		reservation = Reservation.find(params[:id])
		if cleared_for_deletion(current_user, reservation)
			reservation.destroy
			head 204
		else
			head 403
		end
	end

private

	def cleared_for_update(user, reservation)
		same_organization?(user, reservation) && authorized_for_res_update(user)
	end

	def cleared_for_deletion(user, reservation)
		same_organization?(user, reservation) && authorized_for_res_deletion(user, reservation) && reservation.pending?
	end

	def reservation_params
		params.require(:reservation).permit(:client, :representative_id, :quantity, :comment, :date)
	end

	def reservation_update_params
		params.require(:reservation).permit(:status, :visible)
	end

	def handle_reservation_acceptance(reservation)
		service = Service.create_from_reservation(reservation, current_user, 
			Table.where(number: params[:table_number]).first) 
		if !service.new_record?
			render json: reservation, status: 200, location: [ reservation]
		else 
			reservation.pending!
			render json: { errors: service.errors }, status: 422
		end
	end
	
end
