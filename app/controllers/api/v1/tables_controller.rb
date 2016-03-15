class Api::V1::TablesController < ApplicationController

	def index
		date = DateTime.parse(params[:date])
		tables = Table.all
		render json: tables, status: 200, date: date
	end
end
