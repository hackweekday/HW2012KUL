class InfoController < ApplicationController
	set_tab :appliance_management
	def index
		#get constant from license file
		@hw_id, @organization, @support_expiry_date, @license_expiry_date, @serial_number = Dnscell::Utils.device_info
	end
end
