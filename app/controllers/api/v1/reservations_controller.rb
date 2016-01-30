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

	def create
		reservation = current_user.reservations.build(reservation_params)
		if reservation.save
			render json: reservation, status: 201, location: [:api, reservation]
		else
			render json: { errors: reservation.errors }, status: 422
		end
	end

	def update
		reservation = Reservation.find(params[:id])
		if authorized_for_res_update(current_user, reservation) && reservation.update(reservation_update_params)
			Service.create_from_reservation(reservation, current_user) if reservation.accepted?
			render json: reservation, status: 200, location: [:api, reservation]
		else
			if !authorized_for_res_update(current_user, reservation)
				head 403
			else
				render json: { errors: reservation.errors }, status: 422
			end
		end
	end

	def destroy
		reservation = Reservation.find(params[:id])
		if authorized_for_res_deletion(current_user, reservation)
			reservation.destroy
			head 204
		else
			head 403
		end
	end

	private

		def reservation_params
			params.require(:reservation).permit(:client, :representative_id, :quantity, :comment, :date)
		end

		def reservation_update_params
			params.require(:reservation).permit(:status, :visible)
		end
end
