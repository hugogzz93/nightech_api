class Api::V1::ReservationsController < ApplicationController
	respond_to :json
	
	def index
		date = DateTime.parse(params[:date])
		reservations = Reservation.by_date(date)
		if has_clearance?(current_user, "administrator")
			render json: reservations, status: 201
		else
			render json: reservations.where(user_id: current_user.id), status: 201
		end
	end
end
