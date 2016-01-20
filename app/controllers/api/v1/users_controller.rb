class Api::V1::UsersController < ApplicationController
	respond_to :json

	def show
		respond_with User.find(params[:id])
	end

	def create
		user = User.new(user_params)
		if current_user.outranks?(user) && user.save
			render json: user, status: 201, location: [:api, user]
		else
			user.errors[:credentials] = "Insufficient priviledges" unless current_user.outranks? user
			render json: { errors: user.errors }, status: 422
		end
	end

	def update
		user = User.find(params[:id])
		updated_attributes = user == current_user ? self_update_user_params : user_params
		if  authorized_for_update(current_user, user, params[:user]) && user.update(updated_attributes)
			render json: user, status: 200, location: [:api, user]
		else
			user.errors[:credentials] = "Insufficient priviledges" unless authorized_for_update(current_user, user, params[:user])
			render json: { errors: user.errors }, status: 422
		end
	end

	def destroy
		user = User.find(params[:id])
		if authorized_for_deletion(current_user, user)
			user.destroy
			head 204
		else
			head 403	
		end
		
	end

	private 

		def user_params
	      params.require(:user).permit(:email, :password, :password_confirmation, :credentials)
	    end

	    def self_update_user_params
	    	params.require(:user).permit(:email, :password, :password_confirmation)
	    end
end
