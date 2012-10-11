class ServersController < ApplicationController
	set_tab :dns_management
	set_tab :servers, :first_level

	def index
		@servers = Server.order("created_at")
	end

	def new
		@server = Server.new(:tsig => Tsig.new)
	end

	def create
		@zone = Zone.find(params[:zone_id]) unless params[:zone_id].blank?

		unless params[:server].blank?
			if params[:server][:with_tsig] == "1"
				@server = Server.new(params[:server])
			else
				#a["server"]["t"] = a["server"].delete("transaction_signature_attributes")
				params[:server][:tsig_escape_attributes] = params[:server].delete(:tsig_attributes)
				@server = ServerIpOnly.new(params[:server])
			end
		else
			if params[:server_ip_only][:with_tsig] == "1"
				params[:server_ip_only][:tsig_attributes] = params[:server_ip_only].delete(:tsig)
				@server = Server.new(params[:server_ip_only])
			else
				#a["server"]["t"] = a["server"].delete("transaction_signature_attributes")
				params[:server_ip_only][:tsig_escape_attributes] = params[:server_ip_only].delete(:tsig)
				@server = ServerIpOnly.new(params[:server_ip_only])
			end
		end


		if @server.save
			@notice = "Server saved"
			@servers = Server.order("created_at")
			if params[:from] == "zone"
				render 'from_zone.js'
			else
				render 'create.js'
			end
			Resque.enqueue(TsigsServersApplication)
		else
			@error = @server.errors.full_messages
			render 'error.js' 
		end
	end

	def edit
		@server = Server.find(params[:id])

		#@server = :tsig => Tsig.new
		respond_to do |format|
			format.html { }
			format.js { render 'new.js' }
		end
	end

	def update
		unless params[:server].blank?
	 		if params[:server][:with_tsig] == "1"
				@server = Server.find(params[:id])
			else
				params[:server][:tsig_escape_attributes] = params[:server].delete(:tsig_attributes)
				@server = ServerIpOnly.find(params[:id])
				#@server.update_attributes params[:tsig_escape_attributes]
			end
		else
			if params[:server_ip_only][:with_tsig] == "1"
				params[:server_ip_only][:tsig_attributes] = params[:server_ip_only].delete(:tsig)
				@server = Server.find(params[:id])
			else
				params[:server_ip_only][:tsig_escape_attributes] = params[:server_ip_only].delete(:tsig_attributes)
				@server = ServerIpOnly.find(params[:id])
				#@server.update_attributes params[:tsig_escape_attributes]
			end
		end
		
		if @server.update_attributes(params[:server])
			@notice = "Server saved"
			@servers = Server.all
			render 'create.js'
			Resque.enqueue(TsigsServersApplication)
		else
			@error = @server.errors.full_messages
			render 'error.js' 
		end
	end

	def destroy
		server = Server.find(params[:id])
    
		if server.destroy
			Resque.enqueue(TsigsServersApplication)
 			redirect_to servers_path, :notice => "Server deleted!"
    	else
     		redirect_to servers_path, :notice => "Did something wrong?"
   		end
	end
end
