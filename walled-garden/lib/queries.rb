#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

$logger = Logger.new(Rails.root.join("queries_daemon.log"), 10, 1024000)

$logger.formatter = proc do |severity, datetime, progname, msg|
		"#{datetime} #{severity}: #{msg}\n"
end

while($running) do
  
  # Replace this with your code
  #Rails.logger.auto_flushing = true
  #Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  #query_log = "#{ETC_DIR}production/logs-production/query.log"

  remote_log_dir = "/home/named/etc/logs/query.log"

  servers = Server.all
  #s = Server.first
  #servers = ["198.101.192.71", "23.23.193.129"]

  servers.each do |s|
  	#Net::SSH.start(s.ipv4_address, "named") do |ssh|
  	#Check TCP Port 22
  	if Utils.port_test "22" , "#{s.ipv4_address}"
        Net::SSH.start(s.ipv4_address, "named") do |ssh|
	  		channel = ssh.scp.download( remote_log_dir , Rails.root.join(".." , "#{s.name}.log") )
	  		channel.wait

	  		step1 = ssh.exec "rm #{remote_log_dir}"
	  		step1.wait

	  		step2 = ssh.exec "touch #{remote_log_dir}"
	  		step2.wait

	  		step3 = ssh.exec "/home/named/sbin/rndc reload"
  			step3.wait
  		end
  #end

  		query_log = Rails.root.join("..","#{s.name}.log")

		  begin
			  unless File.size(query_log) == 0
				    File.open(query_log, "r").each do |line|
				  	    
				  	    months = {
					  	    "Jan" => "01", "Feb" => "02", "Mar" => "03", "Apr" => "04", "May" => "05", "Jun" => "06", 
					  	    "Jul" => "07", "Aug" => "08", "Sep" => "09", "Oct" => "10", "Nov" => "11", "Dec" => "12"
				  	    }

				    	l = line.split(" ")

				    	#Skip if not met the requirement
				    	next unless l.count == 14
				    	date = l[0].split("-")
				    	date_db = "#{date[2]}-#{months[date[1]]}-#{date[0]}"
				    	time = l[1].split(".")[0]
			        	db_date_time = "#{date_db} #{time}"
			        	server_id = s.id 
				    	client_and_port = l[4].split("#")
			
			            next if client_and_port.count < 2
			
				    	client = client_and_port[0]
				    	port = client_and_port[1].split(":")[0]

				    	view = l[7].split(":")[0]
					    	
				    	query = l[9]
				    	resource = l[11]
				    	flag = l[12]
				    	interface = l[13].split("(")[1].split(")")[0]
				    	#puts "err"
				    	puts "#{date} #{time} #{db_date_time} #{client}  #{port} #{view} #{query} #{resource} #{flag} #{interface}"
				        host = Host.find_by_combine(query)
				
				        unless host.blank?
				        	host_id = host.id
				        	zone_id = host.zone_id
				        	scope = Scope.find_by_combine(host.reference1)
				        	scope_id = scope.id
				        	puts "#{scope_id} #{zone_id}"
				    	else
			                zone_id = nil
			                host_id = nil
			    			Zone.all.each do |zone|
			    				#dnscell.com
			    				z = zone.zone_name.split(".")
			    				#sub.dnscell.com
			    				q = query.split(".")
			
			    				dif = q.count - z.count
			    				
			    				next if dif < 0
			
			    				if dif > 0
			    					q.shift(dif)
			    				end
			
			    				c = q-z
			
			    				if c.blank?
			    					zone_id = zone.id
			    				end
				    		end
						end
							
							today_year, today_month, today_day = date[2], months[date[1]], date[0]
												
							today = date_db
					
							unless zone_id == nil
								#log_zone = ZoneQuery.where(:queries_date => today, :zone_id => zone_id, :resource => resource, :server_id => server_id).first
								
								log_zone = ZoneQuery.where(:queries_date => today, :zone_id => zone_id, :server_id => server_id).first

								if log_zone.nil?
									log_zone = ZoneQuery.create(:queries_date => today, :zone_id => zone_id, :server_id => server_id)
								end
				
								log_zone_id = log_zone.id
				
								if host_id == nil
									ZoneQuery.increment_counter(:invalid_hosts_count, log_zone_id)	
								end
								ZoneQuery.increment_counter(:queries_count, log_zone_id)

								log_total_zone = ZoneDailyQuery.where(:queries_date => today, :zone_id => zone_id, :server_id => server_id).first	
								#log_total_zone = ZoneDailyQuery.where(:queries_date => today, :zone_id => zone_id).first				
								if log_total_zone.nil?
									log_total_zone = ZoneDailyQuery.create(:queries_date => today, :zone_id => zone_id, :server_id => server_id)
									#log_total_zone = ZoneDailyQuery.create(:queries_date => today, :zone_id => zone_id)
								end
				
								log_total_zone_id = log_total_zone.id
				
								#puts Time.new(today_year,today_month,today_day,0,0,0)
								#puts db_date_time
								puts db_date_time
								puts Time.new(today_year,today_month,today_day,0,0,0).strftime("%Y-%m-%d %H:%M:%S")
				
								if db_date_time > Time.new(today_year,today_month,today_day,0,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_1_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_2_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_3_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_4_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_5_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_6_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_7_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_8_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_9_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_10_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_11_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_12_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_13_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_14_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_15_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_16_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_17_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_18_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_19_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_20_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_21_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_22_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_23_count, log_total_zone_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,24,0,0).strftime("%Y-%m-%d %H:%M:%S")
									ZoneDailyQuery.increment_counter(:log_24_count, log_total_zone_id)
								end
							end
				
							unless host_id == nil
								log_host = HostQuery.where(:queries_date => today, :host_id => host_id, :server_id => server_id, :zone_id => zone_id, :scope_id => scope_id).first
				
								if log_host.blank?
									log_host = HostQuery.create(:queries_date => today, :host_id => host_id, :server_id => server_id, :zone_id => zone_id, :scope_id => scope_id)
								end
				
								log_host_id = log_host.id
				
								log_total_host = HostDailyQuery.where(:queries_date => today, :host_id => host_id, :server_id => server_id, :zone_id => zone_id, :scope_id => scope_id).first				
								if log_total_host.nil?
									log_total_host = HostDailyQuery.create(:queries_date => today, :host_id => host_id, :server_id => server_id, :zone_id => zone_id, :scope_id => scope_id)
								end
								
								HostQuery.increment_counter(:queries_count, log_host_id)


								log_total_host_id = log_total_host.id
				
								if db_date_time > Time.new(today_year,today_month,today_day,0,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_1_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_2_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_3_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_4_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_5_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_6_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_7_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_8_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_9_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_10_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_11_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_12_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_13_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_14_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_15_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_16_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_17_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_18_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_19_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_20_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_21_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_22_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_23_count, log_total_host_id)
								elsif db_date_time > Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,24,0,0).strftime("%Y-%m-%d %H:%M:%S")
									HostDailyQuery.increment_counter(:log_24_count, log_total_host_id)
								end
							end
					    end
					  

				    #File.open(query_log, 'w') {|f| f.write("") }
				    FileUtils.rm query_log
				 end
			rescue Exception => e
				puts e.message 
				$logger.error e.message 
				sleep 60
				retry
			end
		end
     end   
  	sleep 60*2
end
