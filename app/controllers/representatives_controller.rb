class RepresentativesController < ApplicationController
	before_action :authenticate_with_token!, only: [:create]
	respond_to :json

	def show
		representative = Representative.find(params[:id])
		if representative.organization == current_user.organization
			respond_with representative
		else
			head 403
		end
	end

	def index
		respond_with Representative.all.where(organization: current_user.organization)
	end

	def create
		representative = current_user.representatives.build(representative_params)
		representative.organization = current_user.organization
		if representative.save
	      	render json: representative, status: 201, location: [representative]
		else
	     	render json: { errors: representative.errors }, status: 422
		end
	end

	def update
		representative = Representative.find(params[:id])
		if cleared_for_update(current_user, representative) && 
		   representative.update(representative_params)
			render json: representative, status: 200, location: [representative]
		elsif !cleared_for_update(current_user, representative)
		    head 403
		else
			render json: { errors: representative.errors }, status: 422
		end		
	end

	def destroy
		representative = Representative.find(params[:id])
		if cleared_for_deletion(current_user, representative)
			representative.destroy 
			head 204
		else
			head 403
		end
	end

  	private


		def cleared_for_update(user, representative)
			same_organization?(current_user, representative) && authorized_for_rep_update(current_user, representative)
		end

		def cleared_for_deletion(user, representative)
			same_organization?(current_user, representative) && authorized_for_rep_deletion(current_user, representative)
		end

    	def representative_params
	      params.require(:representative).permit(:name)
	    end
end
