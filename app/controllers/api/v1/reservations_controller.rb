class Api::V1::ReservationsController < ApplicationController
	respond_to :json
	
	def index
		date = DateTime.parse(params[:date])
		reservations = Reservation.by_date(date)
		if has_clearance?(current_user, "administrator")
			render json: reservations, status: 200
		else
			render json: reservations.where(user_id: current_user.id), status: 200
		end
	end

	def update
		reservation = Reservation.find(params[:id])
		if authorized_for_res_update(current_user, reservation) && reservation.update(reservation_params)
			render json: reservation, status: 200, location: [:api, reservation]
		else
			if !authorized_for_res_update(current_user, reservation)
				head 403
			else
				render json: { errors: reservation.errors }, status: 422
			end
		end
	end

	private

	def reservation_params
		params.require(:reservation).permit(:status, :visible)
	end
end
