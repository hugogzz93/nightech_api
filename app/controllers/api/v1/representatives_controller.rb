class Api::V1::RepresentativesController < ApplicationController
	before_action :authenticate_with_token!, only: [:create]
	respond_to :json

	def show
		respond_with Representative.find(params[:id])
	end

	def index
		respond_with Representative.all
	end

	def create
		representative = current_user.representatives.build(representative_params)
		if representative.save
	      	render json: representative, status: 201, location: [:api, representative]
		else
	      render json: { errors: representative.errors }, status: 422
		end
	end

	def update
		representative = Representative.find(params[:id])
		if authorized_for_rep_update(current_user, representative) && 
		   representative.update(representative_params)
			render json: representative, status: 200, location: [:api, representative]
		elsif !authorized_for_rep_update(current_user, representative)
		    head 403
		else
			render json: { errors: representative.errors }, status: 422
		end		
	end

	def destroy
		representative = Representative.find(params[:id])
		if authorized_for_rep_deletion(current_user, representative)
			representative.destroy 
			head 204
		else
			head 403
		end
	end

  	private

    	def representative_params
	      params.require(:representative).permit(:name)
	    end
end
