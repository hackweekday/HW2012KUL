class UtilitiesController < ApplicationController
	set_tab :appliance_management
  set_tab :dig, :first_level, :only => %w(dig)
  set_tab :ping, :first_level, :only => %w(ping)
  set_tab :traceroute, :first_level, :only => %w(traceroute)
  set_tab :whois, :first_level, :only => %w(whois)


  def index
    redirect_to dig_utilities_path
  end


  def ping
  	data = params[:data]
    
    if data != nil
         check_ip_address = ZoneOptIp.new(:ip_address => data)
         check_domain_name = Host.new(:combine => data, :subdomain => "nil")
         if check_ip_address.valid? or check_domain_name.valid?
          @header = "Ping for #{data}"
          @result = data
         
         end
    end
  end

  def whois
  	data = params[:data]
    
    if data != nil
         check_ip_address = ZoneOptIp.new(:ip_address => data)
         check_domain_name = Host.new(:combine => data, :subdomain => "nil")
         if check_ip_address.valid? or check_domain_name.valid?
          @header = "Whois for #{data}"
          @result = data
         
         end
    end
  end

  def dig
    data = params[:data]
    server = params[:server]
    query = params[:query]
    option = params[:option]

    if data != nil && server != nil
         check_ip_address1 = ZoneOptIp.new(:ip_address => data)
         check_domain_name1 = Host.new(:combine => data, :subdomain => "nil")
         if check_ip_address1.valid? || check_domain_name1.valid? 

            check_ip_address2 = ZoneOptIp.new(:ip_address => server)
            check_domain_name2 = Host.new(:combine => server, :subdomain => "nil")
            
            if check_ip_address2.valid? || check_domain_name2.valid?
              @data = data
              @server = server
              @query = query
              @option = option
            
            end
         end
    end
   
       
  end

  def traceroute
  	data = params[:data]
    
    if data != nil
         check_ip_address = ZoneOptIp.new(:ip_address => data)
         check_domain_name = Host.new(:combine => data, :subdomain => "nil")
         if check_ip_address.valid? or check_domain_name.valid?
            @header = "Traceroute for #{data}"
            @result = data
         end
    end
  end

  def ntp
    @option == "2"
  end
       # redirect_to ping_index_path
	
 def ipv4_ping
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

  def ipv6_ping
    address = params[:address]
    if ValidateHost.new(:host => address).valid? || ValidateIp.new(:ip => address).valid?
      p = `ping6 -c1 -I #{params[:id]} #{address}`
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

end
