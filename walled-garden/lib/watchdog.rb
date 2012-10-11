#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  #Rails.logger.auto_flushing = true
  #Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  #This daemon is for monitoring any NS server a,b,local...
  #port 22,53,953 - if something wrong

  #amir_tel = "0123121979"
  #user_hash = {"amir@localhost.my" => "0123121979", "ahmad@localhost.my" => "0172931521", "ajmal@localhost.my" => "0125704806"}
  servers = Server.all
  servers.each do |server|
  	unless Utils.port_test 22, server.ipv4_address
  		if server.ssh_status
  			server.ssh_status = false
  			server.save(:validate => false)
        	Utils.send_sms "port 22 for #{server.name} is currently down"
        end
    else
    	unless server.ssh_status
  			server.ssh_status = true
  			server.save(:validate => false)
        	Utils.send_sms "port 22 for #{server.name} is now okay"
        end
    end

    unless Utils.port_test 53, server.ipv4_address
    	if server.dns_status
  			server.dns_status = false
  			server.save(:validate => false)
      		Utils.send_sms "port 53 for #{server.name} is currently down"
      	end
    else
    	unless server.dns_status
  			server.dns_status = true
  			server.save(:validate => false)
        	Utils.send_sms "port 53 for #{server.name} is now okay"
        end
    end

    unless Utils.port_test 953, server.ipv4_address
    	if server.rndc_status
  			server.rndc_status = false
  			server.save(:validate => false)
       	Utils.send_sms "port 953 for #{server.name} is currently down" 
      end
    else
    	unless server.rndc_status
  			server.rndc_status = true
  			server.save(:validate => false)
        Utils.send_sms "port 953 for #{server.name} is now okay"
      end
    end
  end

  	# Do we need write to file? 

  	file_53 = Rails.root.join("lib", "daemons", "local_53.txt")
    
    unless FileTest.exists?(file_53)
      status_53 = true
      File.open(file_53, 'w') {|f| f.write(status_53) }
    else
      status_53 = File.open(file_53, 'r') {|f| f.gets }.chomp
    end

    

	unless Utils.port_test 53, "127.0.0.1"
		puts status_53
		if status_53 == "true"
			status_53 = false
			File.open(file_53, 'w') {|f| f.write(status_53) }
	  		Utils.send_sms "port 53 for nucleus.dnssocial.com is currently down"
	  	end
	else
		if status_53 == "false"
			status_53 = true
			File.open(file_53, 'w') {|f| f.write(status_53) }
	    	Utils.send_sms "port 53 for nucleus.dnssocial.com is now okay"
	    end
	end

	file_953 = Rails.root.join("lib", "daemons", "local_953.txt")
    
    unless FileTest.exists?(file_953)
      status_953 = true
      File.open(file_953, 'w') {|f| f.write(status_953) }
    else
      status_953 = File.open(file_953, 'r') {|f| f.gets }.chomp
    end

	unless Utils.port_test 953, "127.0.0.1"
		puts status_953
		if status_953 == "true"
			status_953 = false
			File.open(file_953, 'w') {|f| f.write(status_953) }
	   		Utils.send_sms "port 953 for nucleus.dnssocial.com is currently down" 
	   	end
	else
		if status_953 == "false"
			status_953 = true
			File.open(file_953, 'w') {|f| f.write(status_953) }
	    Utils.send_sms "port 953 for nucleus.dnssocial.com is now okay"
	  end
	end

  puts "dah"
  
  sleep 60*10
end