class Api::V1::RepresentativesController < ApplicationController
	respond_to :json
	
	def show
		respond_with Representative.find(params[:id])		
	end

	def index
		respond_with Representative.all
	end
end
