class PagesController < ApplicationController

	def index
		render :template => 'pages/notification'
	end

	def help
		render :template => 'pages/help'
	end
	
end
