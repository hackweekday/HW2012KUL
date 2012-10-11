class PublicController < ApplicationController

	layout 'login'
  
  
	def about
		set_tab :about
	end

	def contact
		set_tab :contact
	end

	def connection_test
		set_tab :connection_test
	end

	def connection_check_v6
		
		begin
			response = HTTParty.get('http://v6.dnssocial.com/myapi/v1/ip')
		rescue
			response = {:result => "N/A"}
		end

		msg = response
		
    	render :json => msg.to_json
	end

	def connection_check_v4	
		begin
			response = HTTParty.get('http://v4.dnssocial.com/myapi/v1/ip')
		rescue
			response = {:result => "N/A"}
		end

		msg = response
		
    	render :json => msg.to_json
	end

	def connection_check_version
		begin
			response = HTTParty.get('http://ds.dnssocial.com/myapi/v1/ip?version=true')
		rescue
			response = {:result => "N/A"}
		end

		msg = response
		
    	render :json => msg.to_json
	end
end
