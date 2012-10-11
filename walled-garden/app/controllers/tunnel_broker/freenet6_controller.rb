class TunnelBroker::Freenet6Controller < ApplicationController
	set_tab :appliance_management
	set_tab :freenet6, :first_level
	set_tab :info, :second_level, :only => %w(info)
	set_tab :setup, :second_level, :only => %w(setup)
	set_tab :log, :second_level, :only => %w(log)
	set_tab :test, :second_level, :only => %w(test)
	
	#skip_before_filter :set_timezone
	before_filter :set_timezone
	
	def index
		redirect_to :action => :info
	end

	def show
	end

	def info
		@tun = %x{ruby #{Rails.root}/lib/tun.rb} 
		if @tun.empty?
			@tun = "No IPv6 address."
		elsif @tun =~ /options/
			@tun = "Waiting for link-local address."
		end
	end

	def setup
		@broker = Freenet6.first
		if @broker.nil?
			@broker = Freenet6.new
			@broker.address = "broker.freenet6.net"
		end
	end

	def save
		@broker = Freenet6.first
		if @broker.nil?
			@broker = Freenet6.new(params[:freenet6])
			saved = @broker.save ? true : false
		else
			saved = @broker.update_attributes(params[:freenet6]) ? true : false
		end
		if saved
			render :js => "show_flash('Tunnel broker has been successfully updated.');$('.my_error_msg').hide();$('#freenet6_password').val('')"
		else
	          render :js => "show_error(eval(#{@broker.errors.full_messages}))"
	       # logger.debug "$$ #{@error}"
	        #render 'error.js'
		end
	end
	
	def log 
		@logs = Freenet6Log.order("date_time desc")
	end
	
	def set_timezone
		Time.zone = "UTC"
	end

	def save_setting
		Option.find_or_initialize_by_statement(params[:statement]).update_attributes(:statement_value => params[:statement_value])
		render :nothing => true
	end

	def ping
		address = params[:address]
		if ValidateHost.new(:host => address).valid? || ValidateIp.new(:ip => address).valid?
			p = `ping6 -c1 -I tun0 #{address}`
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

	def logs
		@logs = Freenet6Log.where("msg like ?", "%#{params[:sSearch]}%").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength]).order("date_time #{params[:sSortDir_0]}")
		@logs_count = @logs.count
	end
end
