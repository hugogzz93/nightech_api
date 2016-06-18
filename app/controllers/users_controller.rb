class UsersController < ApplicationController
	respond_to :json

	def index
		render json: current_user.super? ? User.where(organization: current_user.organization).where.not(id: current_user.id) : current_user.subordinates, status: 200, location: [ current_user]
	end

	def show
		respond_with User.find(params[:id])
	end

	def create
		user = User.new(user_params)
		user.organization = current_user.organization
		if current_user.outranks?(user) && user.save
			render json: user, status: 201, location: [ user]
		else
			user.errors[:credentials] = 'Insufficient priviledges' unless current_user.outranks? user
			render json: { errors: user.errors }, status: 422
		end
	end

	def update
		user = User.find(params[:id])
		updated_attributes = user == current_user ? self_update_user_params : user_params
		if  cleared_for_update?(current_user, user, params[:user]) && user.update(updated_attributes)
			render json: user, status: 200, location: [ user]
		elsif !cleared_for_update?(current_user, user, params[:user])
			head 403
		else
			render json: { errors: user.errors }, status: 422
		end
	end

	def destroy
		user = User.find(params[:id])
		if cleared_for_deletion?(current_user, user)
			user.destroy
			head 204
		else
			head 403	
		end
		
	end

	private 

		def cleared_for_deletion?(deleting_user, deletee)
			deleting_user.organization == deletee.organization && authorized_for_user_deletion(deleting_user, deletee)
		end

		def cleared_for_update?(deleting_user, deletee, new_attributes)
			deleting_user.organization == deletee.organization && authorized_for_user_update(deleting_user, deletee, new_attributes)
		end

		def user_params
	      params.require(:user).permit(:name, :email, :password, :password_confirmation, :credentials)
	    end

	    def self_update_user_params
	    	params.require(:user).permit(:name, :email, :password, :password_confirmation)
	    end
end
