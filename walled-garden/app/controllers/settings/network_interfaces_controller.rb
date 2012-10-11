class Settings::NetworkInterfacesController < ApplicationController
	set_tab :appliance_management
	set_tab :network_interface, :first_level
	set_tab :hostname, :second_level, :only => %w(hostname)
	set_tab :ipv4, :second_level, :only => %w(ipv4)
	set_tab :ipv6, :second_level, :only => %w(ipv6)

	def index
		redirect_to :action => :ipv4, :id => NetworkSetting.first
	end
	def hostname
		get_interface
	end
	def ipv4
		get_interface
		# ip_split = @interface.ipv4_address.split(".")
		# @interface.ipv4_address_segment1 = ip_split[0]
		# @interface.ipv4_address_segment2 = ip_split[1]
		# @interface.ipv4_address_segment3 = ip_split[2]
		# @interface.ipv4_address_segment4 = ip_split[3]

		# gw_split = @interface.ipv4_gateway.split(".")
		# @interface.ipv4_gateway_segment1 = gw_split[0]
		# @interface.ipv4_gateway_segment2 = gw_split[1]
		# @interface.ipv4_gateway_segment3 = gw_split[2]
		# @interface.ipv4_gateway_segment4 = gw_split[3]
	end

	def ipv4_save
		get_interface
		@interface.em = params[:id]
		
		# params[:network_setting][:ipv4_address] = "#{params[:network_setting][:ipv4_address_segment1]}.#{params[:network_setting][:ipv4_address_segment2]}.#{params[:network_setting][:ipv4_address_segment3]}.#{params[:network_setting][:ipv4_address_segment4]}"
		# params[:network_setting][:ipv4_gateway] = "#{params[:network_setting][:ipv4_gateway_segment1]}.#{params[:network_setting][:ipv4_gateway_segment2]}.#{params[:network_setting][:ipv4_gateway_segment3]}.#{params[:network_setting][:ipv4_gateway_segment4]}"
		if @interface.update_attributes(params[:network_setting])
			
			em_template = "inet #{params[:network_setting][:ipv4_address]} netmask #{params[:network_setting][:ipv4_subnetmask]}"
			param = "ifconfig_em0"
			r = RcSetting.where(:parameter => param).first
			if r.nil?
				RcSetting.create(:parameter => param, :value => em_template, :group => "network")
			else
				r.update_attributes(:value => em_template)
			end
			Cmd.create_rc

			logger.debug "xx ok"
			render :js => "
			show_flash('Saved.');
			$('.form').dialog('close');
			$('.ipv4_address').html('#{params[:network_setting][:ipv4_address]}')
			$('.ipv4_subnetmask').html('#{params[:network_setting][:ipv4_subnetmask]}')
			$('.ipv4_gateway').html('#{params[:network_setting][:ipv4_gateway]}')
			hide_errors()
			"
		else
			logger.debug "xx ko"
			render :js => "show_error(eval(#{@interface.errors.full_messages}))"
		end
	end

	def ipv6_save
		get_interface
		if @interface.update_attributes(params[:network_setting])
		
			if params[:network_setting][:ipv6_auto_configure] == "1"
		    param = "inet6 accept_rtadv"
		  else
		  	param = "inet6 #{@interface.ipv6_address} prefixlen #{@interface.ipv6_prefix}"
		  end
		  
		  r = RcSetting.where(:parameter => "ifconfig_em0_ipv6").first
			if r.nil?
				RcSetting.create(:parameter => "ifconfig_em0_ipv6", :value => param, :group => "ipv6")
			else
				r.update_attributes(:value => param)
			end
			Cmd.create_rc

			render :js => "
			show_flash('Saved.');
			$('.form').dialog('close');
			$('.ipv6_auto_configure').html('#{params[:network_setting][:ipv6_auto_configure].gsub(/0|1/, "0" => "false", "1" => "true")}')
			$('.ipv6_address').html('#{@interface.ipv6_address}')
			$('.ipv6_prefix').html('#{@interface.ipv6_prefix}')
			$('.ipv6_gateway').html('#{@interface.ipv6_gateway}')
			$('.non_auto').#{@interface.ipv6_auto_configure.to_s.gsub(/true|false/, "true" => "hide", "false" => "show")}()
			hide_errors()
			"
		else
			logger.debug "xx ko"
			render :js => "show_error(eval(#{@interface.errors.full_messages}))"
		end
	end

	def ipv6
		get_interface
		case @interface.ipv6_type
		when "native"
			# unless @interface.ipv6_address.nil?
			# 	ip_split = @interface.ipv6_address.split(":")
			# 	@interface.ipv6_segment1 = ip_split[0]
			# 	@interface.ipv6_segment2 = ip_split[1]
			# 	@interface.ipv6_segment3 = ip_split[2]
			# 	@interface.ipv6_segment4 = ip_split[3]
			# 	@interface.ipv6_segment5 = ip_split[4]
			# 	@interface.ipv6_segment6 = ip_split[5]
			# 	@interface.ipv6_segment7 = ip_split[6]
			# 	@interface.ipv6_segment8 = ip_split[7]

			# 	gw_split = @interface.ipv6_gateway.split(":")
			# 	# @interface.ipv4_gateway_segment1 = gw_split[0]
			# 	# @interface.ipv4_gateway_segment2 = gw_split[1]
			# 	# @interface.ipv4_gateway_segment3 = gw_split[2]
			# 	# @interface.ipv4_gateway_segment4 = gw_split[3]
			# 	@interface.ipv6_gateway_segment1 = gw_split[0]
			# 	@interface.ipv6_gateway_segment2 = gw_split[1]
			# 	@interface.ipv6_gateway_segment3 = gw_split[2]
			# 	@interface.ipv6_gateway_segment4 = gw_split[3]
			# 	@interface.ipv6_gateway_segment5 = gw_split[4]
			# 	@interface.ipv6_gateway_segment6 = gw_split[5]
			# 	@interface.ipv6_gateway_segment7 = gw_split[6]
			# 	@interface.ipv6_gateway_segment8 = gw_split[7]
			# end
		when "freenet"
			@broker = Freenet6.first
			if @broker.nil?
				@broker = Freenet6.new
				@broker.address = "broker.freenet6.net"
			end
			@tun = %x{ruby lib/tun.rb} 
			if @tun.empty?
				@tun = "No IPv6 address."
			elsif @tun =~ /options/
				@tun = "Waiting for link-local address."
			end
		when "he.net"
			@henet_local_ipv4 = Option.find_or_initialize_by_statement("henet_local_ipv4").statement_value
			@henet_server_ipv4 = Option.find_or_initialize_by_statement("henet_server_ipv4").statement_value
			@henet_local_ipv6 = Option.find_or_initialize_by_statement("henet_local_ipv6").statement_value
			@henet_server_ipv6 = Option.find_or_initialize_by_statement("henet_server_ipv6").statement_value
		end
	end

	def get_interface #ipv4_gateway
		if NetworkSetting.all.map{|x| x.ipv6_state }.select{|x| x == true }.empty?
			@ipv6_state = false
		else
			@ipv6_state = true
		end
		# logger.debug "@ipv6_state #{@ipv6_state}"
		# @ipv6_state = Option.find_by_statement("ipv6_state")
		# @ipv6_state = NetworkSetting.find_by_interface(params[:id]).ipv6_state
		@ipv4_gateway = Option.find_or_initialize_by_statement("ipv4_gateway")
		@ipv6_gateway = Option.find_or_initialize_by_statement("ipv6_gateway")
		@hostname = Option.find_or_initialize_by_statement("hostname")
		@interface = NetworkSetting.find_by_interface(params[:id])
		logger.debug "xx #{@interface}"
		@interfaces = NetworkSetting.all
	end

	def ipv6_switch
		get_interface
		if @interface.update_attribute(:ipv6_state, params[:t].gsub(/true|false/, "true" => "true", "false" => "false"))
		  Cmd.create_rc
			render :js => "
			show_flash('IPv6 #{params[:t].gsub(/true|false/, "true" => "Activated", "false" => "Deactivated")}.')
			$('.ipv6').#{params[:t].gsub(/true|false/, "true" => "show", "false" => "hide")}()
			if ('#{params[:t]}' == 'true'){
				// $('.before_second_level > li:visible:last').removeClass('last')
				// $('.before_second_level > li:last').show()
				// $('.tab_ipv6').show()
				// $('.tab_ipv6').prev().removeClass('last')
				// $('.ipv6_gateway').show()
			} else {
				// $('.before_second_level > li:last').hide()
				// $('.before_second_level > li:visible:last').addClass('last')
				// $('.tab_ipv6').hide()
				// $('.tab_ipv6').prev().addClass('last')
				// $('.ipv6_gateway').hide()
			}
			"
		end
	end

	def save_hostname
		get_interface
		if @hostname.update_attributes(:statement_value => params[:option][:statement_value])
			
			#Add by amir dude
			r = RcSetting.where(:parameter => "hostname").first
			if r.nil?
				RcSetting.create(:parameter => "hostname", :value => params[:option][:statement_value], :group => "network")
			else
				r.update_attributes(:value => params[:option][:statement_value])
			end
			Cmd.create_rc
			%x{sudo hostname #{params[:option][:statement_value]}}
			
		logger.debug "#{params[:option][:statement_value]}"
		
			render :js => "
				show_flash('Saved.');
				$('.hostname_form').dialog('close');
				$('.hostname').html('#{@hostname.statement_value}');
				hide_errors()"
		else
			render :js => "show_error(#{@hostname.errors.full_messages})"
		end
	end

	def save_gateway
		get_interface
		if eval("@#{params[:type]}_gateway").update_attributes(:statement_value => params[:statement_value])
			#Add by amir dude
			unless params[:type] == "ipv6"
				r = RcSetting.where(:parameter => "defaultrouter").first
				if r.nil?
					RcSetting.create(:parameter => "defaultrouter", :value => params[:statement_value], :group => "network")
				else
					r.update_attributes(:value => params[:statement_value])
				end
			else
				r = RcSetting.where(:parameter => "ipv6_defaultrouter").first
				if r.nil?
					RcSetting.create(:parameter => "ipv6_defaultrouter", :value => params[:statement_value], :group => "network")
				else
					r.update_attributes(:value => params[:statement_value])
				end
			end
			Cmd.create_rc

			render :js => "
				show_flash('Saved.');
				$('.gateway_form').dialog('close');
				$('.#{params[:type]}_gateway').html('#{eval("@#{params[:type]}_gateway").statement_value}');
				hide_errors()"
		else
			render :js => "show_error(eval(#{eval("@#{params[:type]}_gateway").errors.full_messages}))"
		end
	end


	def load_ipv6_type
		get_interface
		@interface.update_attribute(:ipv6_type, params[:ipv6_type])
		# render :action => :ipv6, :id => @interface
		redirect_to ipv6_settings_network_interface_path(@interface)
	end

	def save_henet
		arr = ["henet_local_ipv4","henet_server_ipv4","henet_local_ipv6", "henet_server_ipv6"]
		@errors = []
		arr.each do |h|
			a = Option.find_or_initialize_by_statement(h)
			if a.update_attributes(:statement_value => params[h])
			else
				@errors.push(a.errors.full_messages)
			end
		end
		unless @errors.empty?
			render :js => "show_error(#{@errors})"
		else
			render :js => "
			show_flash('Saved');hide_errors()
			$('.henet_local_ipv4').html('#{params[:henet_local_ipv4]}')
			$('.henet_server_ipv4').html('#{params[:henet_server_ipv4]}')
			$('.henet_local_ipv6').html('#{params[:henet_local_ipv6]}')
			$('.henet_server_ipv6').html('#{params[:henet_server_ipv6]}')
			$('.form').dialog('close')
			"
		end
	end	

  def ipv6_ping
    address = params[:address]
    if ValidateHost.new(:host => address).valid? || ValidateIp.new(:ip => address).valid?
      p = `ping6 -c1 #{address}`
      unless p.split("\n").empty?
        p = "<br>" + p.split("\n")[1]
      else
        p = "<br>Unable to ping"
      end
      render :js => "$('.ping_result > pre:first').prepend('#{p}');$('.blink').hide()"
    else
      render :js => "$('.ping_result > pre:first').prepend('<br>Invalid address');$('.blink').hide();clearTimeout(t);$('.ping').html('Start Ping')"
    end
  end

  def ipv4_ping
    address = params[:address]
    if ValidateHost.new(:host => address).valid? || ValidateIp.new(:ip => address).valid?
      p = `ping -c1 #{address}`
      unless p.split("\n").empty?
        p = "<br>" + p.split("\n")[1]
      else
        p = "<br>Unable to ping"
      end
      render :js => "$('.ping_result4 > pre:first').prepend('#{p}');$('.blink').hide()"
    else
      render :js => "$('.ping_result4 > pre:first').prepend('<br>Invalid address');$('.blink').hide();clearTimeout(t);$('.ping').html('Start Ping')"
    end
  end

  def gateway
	  get_interface	
  end

  def freenet
  	get_interface
		@broker = Freenet6.first
		if @broker.nil?
			@broker = Freenet6.new
			@broker.address = "broker.freenet6.net"
		end
		@tun = %x{ruby lib/tun.rb} 
		if @tun.empty?
			@tun = "No IPv6 address."
		elsif @tun =~ /options/
			@tun = "Waiting for link-local address."
		end

  end

  def henet
  	get_interface
	@henet_local_ipv4 = Option.find_or_initialize_by_statement("henet_local_ipv4").statement_value
	@henet_server_ipv4 = Option.find_or_initialize_by_statement("henet_server_ipv4").statement_value
	@henet_local_ipv6 = Option.find_or_initialize_by_statement("henet_local_ipv6").statement_value
	@henet_server_ipv6 = Option.find_or_initialize_by_statement("henet_server_ipv6").statement_value
  end

  def test
  	get_interface
  end

  def henet_switch
  	henet = Option.find_or_initialize_by_statement("henet_state")
  	if henet.update_attributes(:statement_value => params[:q])
  		render :js => "
  		$('.henet').#{params[:q].gsub(/true|false/, "true" => "show", "false" => "hide" )}()
  		show_flash('He.net #{params[:q].gsub(/true|false/, "true" => "Activated", "false" => "Deactivated" )}')
  		"
  	end
  end

  def freenet_switch
  	freenet = Freenet6.first
  	freenet.from_seed = true
  	if freenet.update_attributes(:state => params[:q])
  		
  		if params[:q]
	  		r = RcSetting.where(:parameter => "gogoc_enable").first
				if r.nil?
					RcSetting.create(:parameter => "gogoc_enable", :value => "YES", :group => "gogoc")
				else
					r.update_attributes(:status => true)
				end
			else
			  %x{sudo /usr/local/etc/rc.d/gogoc stop}
				%x{sudo ifconfig tun0 destroy}
				r = RcSetting.where(:parameter => "gogoc_enable").first
				unless r.nil?
					r.update_attributes(:status => false)					
				end
			end			
			Cmd.create_rc
			
  		render :js => "
  		$('.freenet').#{params[:q].gsub(/true|false/, "true" => "show", "false" => "hide" )}()
  		show_flash('Freenet #{params[:q].gsub(/true|false/, "true" => "Activated", "false" => "Deactivated" )}')
  		"
  	end
  end
end