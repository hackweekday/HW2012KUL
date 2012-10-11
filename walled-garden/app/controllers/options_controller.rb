class OptionsController < ApplicationController
	def index
		@options = Option.all
	    bh_method = get_option("blackhole")
	    if bh_method == "1"
	      @bh_partial = "zones/zone_opt/ip_ls"
	    else
	      @bh_partial = "zones/zone_opt/acl_ls"
	    end
		@listen_ipv4_partial = "zones/zone_opt/ip_ls"
		@listen_ipv6_partial = "zones/zone_opt/ip_ls"
	    recursive_data_query bh_method, "blackhole"
	    recursive_data_query "1", "ipv4"
	    recursive_data_query "1", "ipv6"
	end

	def edit
		case params[:t] 
		when "version"
			@options = Option.find_by_statement("version")
		end
	end

	def save
		@options = Option.find_by_statement(params[:t])
		if @options.update_attributes(params[:option])
		else
			@error = @options.errors.full_messages
			render 'error.js'
		end
	end


	  def recursive_data_query m, t
	    @options = Option.all
	    case m
	    when "1"
	      case t
			when "allow-recursion"
				@ar_ips = OptionIp.where(:typ => t).order("position")
			when "blackhole"
				@bh_ips = OptionIp.where(:typ => t).order("position")
			when 'forwarders'
				@f_ips = OptionIp.where(:typ => t).order("position")
			when "ipv4"
				@ipv4_ips = OptionIp.where(:typ => t).order("position")
			when "ipv6"
				@ipv6_ips = OptionIp.where(:typ => t).order("position")
	      end
	      @ip = OptionIp.new
	    when "3"
	      case t
	      when "allow-recursion"
	        @ar_acls = RecursiveAcl.where(:method => t).order("position")
	      when "blackhole"
	        @bh_acls = RecursiveAcl.where(:method => t).order("position")
	        # render :js => "alert('hehe')"
	      end
	      @acl_names = AclName.all
	      @acl = RecursiveAcl.new
	    end
	  end
  
end
