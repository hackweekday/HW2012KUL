module Admin
	class BaseController < ApplicationController
		before_filter :authenticate_user!
		before_filter :only_admin
		#skip_filter :sign_in
		private
		def only_admin
			unless current_user.admin 
				redirect_to new_user_session_path
			end
		end
	end
end