class ZoneUploadController < ApplicationController
	def index
		render :layout => 'application_without_sidebar'
	end

	def new
		@zone_upload = ZoneUpload.new
		render :layout => 'application_without_sidebar'
	end

	def create
		@zone_upload = ZoneUpload.new(params[:zone_upload])
		@zone_upload.template_id = params[:template_id]
		if @zone_upload.save
			#We need to validate here?
			validate = Dnscell::Utils.validate_zone_file @zone_upload.zone_name, @zone_upload.zone_file.current_path
			unless validate
				@zone_upload.errors.add("","Your zone file is invalid")
				@error_msg = Dnscell::Utils.get_error_from_validate_zone_file @zone_upload.zone_name, @zone_upload.zone_file.current_path
				@errors = []
          		@zone_upload.errors.each {|x| @errors << @zone_upload.errors[x]}
          		@zone_upload.destroy
          		#DNSSEC please escape duh.. sampah.
				render 'error.js'
			else
				@zone = Zone.new(:zone_name => @zone_upload.zone_name, :zone_type => "master", :template_id => @zone_upload.template_id)
    			@zone.allow_query = 1
    			@zone.user_id = current_user.id
    			@zone.save
    			ZoneOptIp.create(:zone_id => @zone.id, :ip_address => "any", :status => 1, :read_only => 0, :allow => 1, :typ => "allow-query")
    			Resque.enqueue(CreateZoneApplication, @zone)
    			Resque.enqueue(ProcessZoneApplication, @zone.id, current_user.id)
			end
		else
			@errors = []
          	@zone_upload.errors.each {|x| @errors << @zone_upload.errors[x]}
			render 'error.js'
		end
	end
end
