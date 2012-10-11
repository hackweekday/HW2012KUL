class Api::V1::CreateController < API::V1::ApplicationController
	before_filter :authenticate_node

	def slave
		zone_name = params[:zone_name]
		z = Zone.find_by_zone_name(zone_name)

		if zone_name.blank?
			render :json => {:error => "Blank"}
		elsif z.nil?
			@zone = Zone.new(:zone_name => zone_name, :zone_type => "slave", :user_id => current_user.id, :node_id => params[:node_id])
			if @zone.save
				NodeUtils.create_server(get_ip, @zone.id)
				render :json => {:status => :created}
			else
				@errors = []
         		@zone.errors.each {|x| @errors << @zone.errors[x]}
				render :json => {:error => @errors.join}
			end
		else
			render :json => {:error => "Zone already exist"}
		end
	end

	private

	def authenticate_node
		node_id = params[:node_id]
		remote_ip = get_ip
		node = Node.where(:id => node_id).first
		if node.nil?
			render :json => {:error => "Invalid node"}
		else
			if node.status != 1
				render :json => {:error => "Waiting for approval"}
			else
				addrs = node.node_addresses
				if addrs.empty?
					render :json => {:error => "Error: IP"}
				else
					ip = Array.new
					addrs.each {|i| ip << i.ip}
					unless ip.include? remote_ip
						render :json => {:error => "Unauthorized"}
					end
				end

			end
		end
	end
end