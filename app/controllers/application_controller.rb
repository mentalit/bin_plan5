class ApplicationController < ActionController::Base




	private

	def get_store
		@store = Store.find(params[:store_id])
	end
end
