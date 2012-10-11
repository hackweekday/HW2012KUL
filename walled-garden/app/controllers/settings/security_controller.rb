class Settings::SecurityController < ApplicationController
  set_tab :security, :first_level
  set_tab :firewall, :second_level, :only => %w(index)
  set_tab :brute_force, :second_level, :only => %w(brute_force)

  def index
    puts "aa"
    @ip = OptionIp.new
    status = (o "dns_filter_access_method") == "whitelist" ? 1 : 0
    @dns_ips = OptionIp.where(:typ => "dns", :status => status)
    @gui_ips = OptionIp.where(:typ => "gui", :status => status)
  end

  def save_address
    ip = OptionIp.new(params[:option_ip])
    ip.status = params[:filter_access] == "whitelist" ? true : false
    ip.typ = params[:dns_gui]
    if ip.save
      change_filter_access
      render 'change_filter_access.js'
    else
      @error = ip.errors.full_messages
      render 'error.js'
    end
  end

  def delete_address
    OptionIp.find(params[:id]).destroy
    change_filter_access
    render 'change_filter_access.js'
  end

  def change_filter_access
    @ip = OptionIp.new
    status = params[:filter_access] == "whitelist" ? 1 : 0
    Option.find_by_statement("#{params[:dns_gui]}_filter_access_method").update_attributes(:statement_value => params[:filter_access])
    eval("@#{params[:dns_gui]}_ips = OptionIp.where(:typ => params[:dns_gui], :status => status)")
  end

  def save_brute_force
    ["commit", "utf8", "authenticity_token", "controller", "action"].each{|x| params.delete(x) }
    logger.debug "$$ #{params}"
    @error = []
    params.each do |p|
      if check_integer(p)
        Option.find_by_statement(p).update_attributes(:statement_value => p[1])
      else
        @error.push("#{p[0]} is not an integer.")
      end
    end
    #update checkboxes

    ["tcp_gui_brute_force_state", "tcp_dns_brute_force_state", "udp_dns_brute_force_state"].each{|c| Option.find_by_statement(c).update_attributes(:statement_value => "false") if params.find{|x| x[0] == c }.nil? }
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
end
