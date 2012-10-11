class SecurityController < ApplicationController
  set_tab :appliance_management
  set_tab :firewall, :first_level, :only => %w(index)
  set_tab :brute_force, :first_level, :only => %w(brute_force)

  def index
    @ip = Firewall.new
    dns_status = (o "dns_filter_access_method") == "whitelist" ? 1 : 0
    gui_status = (o "gui_filter_access_method") == "whitelist" ? 1 : 0
    @dns_ips = Firewall.where(:typ => "dns", :status => dns_status)
    @gui_ips = Firewall.where(:typ => "gui", :status => gui_status)
  end

  def save
    Option.find_or_initialize_by_statement(params[:statement]).update_attributes(:statement_value => params[:statement_value])
    Pf.write_to_pf_conf
    render :nothing
  end

  def save_address
    ip = Firewall.new(params[:firewall])
    ip.status = params[:filter_access] == "whitelist" ? true : false
    logger.debug "xx #{ip.status}"
    ip.typ = params[:dns_gui]
    if ip.save
      Pf.table("add", "#{ip.ip_address}", "#{ip.typ}", ip.status, "#{ip.tcp_udp}")
      change_filter_access
      logger.debug "xx Pf.write"
      render 'change_filter_access.js'
    else
      @error = ip.errors.full_messages
      render 'error.js'
    end
  end

  def delete_address
    ip = Firewall.find(params[:id])
    ip.destroy
    Pf.table("delete", "#{ip.ip_address}", "#{ip.typ}", ip.status, "#{ip.tcp_udp}")
    logger.debug "xx delete_address Pf.write"
    change_filter_access
    render 'change_filter_access.js'
  end

  def change_filter_access
    logger.debug "xx change_filter_access action = #{params[:action]}"
    @ip = Firewall.new
    status = params[:filter_access] == "whitelist" ? 1 : 0
    Option.find_by_statement("#{params[:dns_gui]}_filter_access_method").update_attributes(:statement_value => params[:filter_access])
    Pf.write_to_pf_conf unless params[:action] == "delete_address" || params[:action] == "save_address"
    eval("@#{params[:dns_gui]}_ips = Firewall.where(:typ => params[:dns_gui], :status => status)")
    logger.debug "xx change_filter_access Pf.write"
  end

  def save_brute_force
    ["commit", "utf8", "authenticity_token", "controller", "action"].each{|x| params.delete(x) }
    logger.debug "$$ #{params}"
    @error = []
    params.each do |p|
      puts "xx #{p}"
      unless p[0] == "type"
        if check_integer(p)
          Option.find_by_statement(p).update_attributes(:statement_value => p[1])
        else
          @error.push("#{p[0]} is not an integer.")
        end
      end
    end
    Pf.write_to_pf_conf

    if params[:type] == "dns" && params[:tcp_dns_brute_force_state].nil?
      Option.find_by_statement("tcp_dns_brute_force_state").update_attributes(:statement_value => "false")
    elsif params[:type] == "dns" && params[:tcp_dns_brute_force_state] == "true"
      Option.find_by_statement("tcp_dns_brute_force_state").update_attributes(:statement_value => "true")
    end
    if params[:type] == "gui" && params[:tcp_gui_brute_force_state].nil?
      Option.find_by_statement("tcp_gui_brute_force_state").update_attributes(:statement_value => "false")
    elsif params[:type] == "gui" && params[:tcp_gui_brute_force_state] == "true"
      Option.find_by_statement("tcp_gui_brute_force_state").update_attributes(:statement_value => "true")
    end
    #update checkboxes
    # ["tcp_gui_brute_force_state", "tcp_dns_brute_force_state", "udp_dns_brute_force_state"].each{|c| Option.find_by_statement(c).update_attributes(:statement_value => "false") if params.find{|x| x[0] == c }.nil? }
    unless @error.empty?
      render 'error.js'
    else
      render :js => "show_flash('Saved.');$('.my_error_msg').hide()"
    end
  end

  def check_integer(p)
    case p[0]
    when "tcp_gui_brute_force_second", "tcp_gui_brute_force_request", "tcp_dns_brute_force_request", "tcp_dns_brute_force_second", "udp_dns_brute_force_request", "udp_dns_brute_force_second"
      begin
        Float(p[1])
      rescue
        false
      end
    else
      true
    end
  end

  def brute_force
    http_s = %x{sudo pfctl -q -t http-tcp-attacks -T show}
    @gui_blacklist = http_s.split("\n").collect{|x| x.strip}

    dns_s = %x{sudo pfctl -q -t dns-tcp-attacks -T show}
    @dns_blacklist = dns_s.split("\n").collect{|x| x.strip}
  end

  def delete_blacklist
  	case params[:type]
	when "dns"
		Pf.delete_dns_ip(params[:ip])
	when "gui"
		Pf.delete_http_ip(params[:ip])
	end
	brute_force
  end
end
