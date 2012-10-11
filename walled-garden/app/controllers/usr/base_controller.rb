module Usr
	class BaseController < ApplicationController
		before_filter :authenticate_user!
		#skip_filter :sign_in
	end
end