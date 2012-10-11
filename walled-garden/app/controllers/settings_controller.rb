class SettingsController < ApplicationController
	set_tab :appliance_management
	set_tab :network_interface, :first_level, :only => %w(index network_interface edit_network_interface update_network_interface)
	set_tab :ntp, :first_level, :only => %w(ntp)
	set_tab :smtp, :first_level, :only => %w(smtp)
	set_tab :recipient, :first_level, :only => %w(recipients)
	set_tab :timezone, :first_level, :only => %w(timezone)
	skip_before_filter :set_timezone

	def save
	    Option.find_or_initialize_by_statement(params[:statement]).update_attributes(:statement_value => params[:statement_value])
	    render :nothing => true
	end

	def recipients
		@recipients = Recipient.all
	end

	def index
		redirect_to network_interface_settings_path
	end

	def network_interface
		@interface = NetworkSetting.first
	end

	def edit_network_interface
		@interface = NetworkSetting.first
		ip_split = @interface.ipv4_address.split(".")
		@interface.ipv4_address_segment1 = ip_split[0]
		@interface.ipv4_address_segment2 = ip_split[1]
		@interface.ipv4_address_segment3 = ip_split[2]
		@interface.ipv4_address_segment4 = ip_split[3]

		gw_split = @interface.ipv4_gateway.split(".")
		@interface.ipv4_gateway_segment1 = gw_split[0]
		@interface.ipv4_gateway_segment2 = gw_split[1]
		@interface.ipv4_gateway_segment3 = gw_split[2]
		@interface.ipv4_gateway_segment4 = gw_split[3]
	end

	def update_network_interface
		@interface = NetworkSetting.first
		params[:network_setting][:ipv4_address] = "#{params[:network_setting][:ipv4_address_segment1]}.#{params[:network_setting][:ipv4_address_segment2]}.#{params[:network_setting][:ipv4_address_segment3]}.#{params[:network_setting][:ipv4_address_segment4]}"
		params[:network_setting][:ipv4_gateway] = "#{params[:network_setting][:ipv4_gateway_segment1]}.#{params[:network_setting][:ipv4_gateway_segment2]}.#{params[:network_setting][:ipv4_gateway_segment3]}.#{params[:network_setting][:ipv4_gateway_segment4]}"

		if @interface.update_attributes(params[:network_setting])
			redirect_to network_interface_settings_path
		else
			render 'edit_network_interface'
		end
	end

	def ntp
		#@option == "2"
	end

	def save_ntp
		opt = Option.find_by_statement("ntp_server")
		if opt.update_attributes(:statement_value => params[:server])
			render :js => "show_flash('NTP Server saved.');hide_errors()"
		else
			render :js => "show_error(eval(#{opt.errors.full_messages}))"
		end
	end

	def ntp_update_now
		Ntp.update_now
		render :js => "
		show_flash('Successfully updated.');
		$(\"#clock\").clock(\"destroy\");
		customtimestamp = new Date(#{`date`.to_time.strftime("%Y, %m-1, %d, %H, %M, %S")});
		$(\"#clock\").clock({\"timestamp\":customtimestamp});
		// alert('do update ntp now here')
		"
	end

	def smtp
		@smtp_setting = SmtpSetting.first
		if @smtp_setting.nil?
			@smtp_setting = SmtpSetting.new
		end
		@smtp_setting
	end

	def create_smtp
		@smtp_setting = SmtpSetting.new(params[:smtp_setting])
		if @smtp_setting.save
			redirect_to smtp_settings_path, :notice => "SMTP settings has been saved"
		else
			render 'smtp'
		end
	end

	def update_smtp
		@smtp_setting = SmtpSetting.first
		if @smtp_setting.update_attributes(params[:smtp_setting])
			redirect_to smtp_settings_path, :notice => "SMTP settings has been updated"
		else
			render 'smtp'
		end
	end

	def timezone
		@timezone = TimezoneSetting.first
		@timezone = TimezoneSetting.new if @timezone.nil?
	end

	def location_by_region
		@locations = TimeZone.where(:region => params[:region])
		@timezone = TimezoneSetting.first
		@location = @timezone.location
	end

	def save_timezone
		@timezone = TimezoneSetting.first
		if @timezone.nil?
			@timezone = TimezoneSetting.new(params[:timezone_setting])
			if @timezone.save
				# Cmd.timezone(params[:timezone_setting][:region], params[:timezone_setting][:location])
				render :js => "show_flash('Time zone saved.')"
			else
				render :js => "show_flash('Error while saving time zone.')"
			end
		else		
			if @timezone.update_attributes(params[:timezone_setting])
				render :js => "show_flash('Time zone saved.')"
			else
				render :js => "show_flash('Error while saving time zone.')"
			end
		end
	end

	def shutdown_reboot
		if params[:auth_token] == User.find_by_username("api").authentication_token
			if params[:type] == "Shutdown"
				logger.debug "xx Shut"
				Cmd.shutdown
			elsif params[:type] == "Reboot"
				logger.debug "xx Reboot"
				Cmd.reboot
			end
			render :nothing => true
		else
			render :text => "unauthorized."
		end
	end

	def process_switch
		puts "xx #{params[:type]}"
		if current_user.valid_password?(params[:password])
			process = params[:type].gsub(/[01]/, "0" => "Shutdown", "1" => "Reboot")
			render :js => "
			$('.ui-dialog-content').dialog('close');
			$('.status_message').dialog({
				modal: true, 
				title: 'Status',
				closeOnEscape: false,
				open: function(event, ui) { $('.ui-dialog-titlebar-close').hide(); }
			})
			hide_errors()
			$('.shutdown_password').val('')

			if ('#{process}' == 'Reboot') {
				setTimeout('timedCount()',5000)
				$('.status_message').html('#{process} now. You may want to do something else for now.')
			} else {
				$('.status_message').html('#{process} now. Good Bye.')
			}

			$.ajax({
				url: '#{shutdown_reboot_settings_path}?auth_token=#{User.find_by_username("api").authentication_token}&type=#{process}',
				type: 'get'
				})
			"
		else
			render :js => "show_error([\"Sorry. Wrong password.\"])"
		end
	end
end
