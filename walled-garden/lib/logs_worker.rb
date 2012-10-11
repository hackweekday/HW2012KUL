#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  # Rails.logger.auto_flushing = true
  # Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  query_log = "#{ETC_DIR}production/logs-production/query.log"
  begin
	  unless File.size(query_log) == 0
		    File.open(query_log, "r").each do |line|
		  	    
		  	    months = {
			  	    "Jan" => "01", 
			  	    "Feb" => "02", 
			  	    "Mar" => "03", 
			  	    "Apr" => "04", 
			  	    "May" => "05", 
			  	    "Jun" => "06", 
			  	    "Jul" => "07", 
			  	    "Aug" => "08", 
			  	    "Sep" => "09", 
			  	    "Oct" => "10",
			  	    "Nov" => "11",
			  	    "Dec" => "12"
		  	    }

		    	l = line.split(" ")

		    	next unless l.count == 14
		    	
		    	date = l[0].split("-")

		    	date_db = "#{date[2]}-#{months[date[1]]}-#{date[0]}"
		    	time = l[1].split(".")[0]
	        db_date_time = "#{date_db} #{time}"
	        
	        node_id = Node.find_by_node_type("local").id
		
					if node_id.nil?
						node_id = nil
					end

	        
	        unless l[3] == "client"
	        	category = "query"
		    		severity = l[3].chop
		    		log_message = l[4..l.count].join(" ")
	                NamedLog.create(:date_time => db_date_time,
					        				:category => category,
					        				:severity => severity,
					        				:log_message => log_message,
					        				:node_id => node_id
					        				)
	        else
			    	
		
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
		
					#{date[2]}-#{months[date[1]]}-#{date[0]}
					#today_day, today_month, today_year = Time.now.day, Time.now.month, Time.now.year
					
					today_year, today_month, today_day = date[2], months[date[1]], date[0]
					
					#today = Time.now.strftime("%Y-%m-%d")
					
					today = date_db
		
					#puts today
					#puts today_day
					#puts today_month
					#puts today_year
						
					unless zone_id == nil
						log_zone = LogZoneQuery.where(:queries_date => today, :zone_id => zone_id, :resource => resource, :node_id => node_id).first
						
						if log_zone.nil?
							log_zone = LogZoneQuery.create(:queries_date => today, :zone_id => zone_id, :resource => resource, :node_id => node_id)
						end
		
						log_zone_id = log_zone.id
		
						if host_id == nil
							LogZoneQuery.increment_counter(:invalid_hosts_count, log_zone_id)
						end
		
						log_total_zone = LogTotalZoneQuery.where(:log_date => today, :zone_id => zone_id, :resource => resource, :node_id => node_id).first	
						#log_total_zone = LogTotalZoneQuery.where(:log_date => today, :zone_id => zone_id).first				
						if log_total_zone.nil?
							log_total_zone = LogTotalZoneQuery.create(:log_date => today, :zone_id => zone_id, :resource => resource, :node_id => node_id)
							#log_total_zone = LogTotalZoneQuery.create(:log_date => today, :zone_id => zone_id)
						end
		
						log_total_zone_id = log_total_zone.id
		
						#puts Time.new(today_year,today_month,today_day,0,0,0)
						#puts db_date_time
						puts db_date_time
						puts Time.new(today_year,today_month,today_day,0,0,0).strftime("%Y-%m-%d %H:%M:%S")
		
						if db_date_time > Time.new(today_year,today_month,today_day,0,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_1_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_2_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_3_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_4_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_5_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_6_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_7_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_8_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_9_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_10_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_11_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_12_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_13_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_14_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_15_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_16_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_17_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_18_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_19_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_20_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_21_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_22_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_23_count, log_total_zone_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,24,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalZoneQuery.increment_counter(:log_24_count, log_total_zone_id)
						end
					end
		
					unless host_id == nil
						log_host = LogHostQuery.where(:queries_date => today, :host_id => host_id, :resource => resource, :node_id => node_id).first
		
						if log_host.blank?
							log_host = LogHostQuery.create(:queries_date => today, :host_id => host_id, :resource => resource, :node_id => node_id)
						end
		
						log_host_id = log_host.id
		
						log_total_host = LogTotalHostQuery.where(:log_date => today, :host_id => host_id, :resource => resource, :node_id => node_id).first				
						if log_total_host.nil?
							log_total_host = LogTotalHostQuery.create(:log_date => today, :host_id => host_id, :resource => resource, :node_id => node_id)
						end
		
						log_total_host_id = log_total_host.id
		
						if db_date_time > Time.new(today_year,today_month,today_day,0,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_1_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_2_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_3_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_4_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_5_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_6_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_7_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_8_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_9_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_10_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_11_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_12_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_13_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_14_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_15_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_16_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_17_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_18_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_19_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_20_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_21_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_22_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_23_count, log_total_host_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,24,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalHostQuery.increment_counter(:log_24_count, log_total_host_id)
						end
					end

					#Global
						log_global = LogGlobalQuery.where(:queries_date => today, :resource => resource, :node_id => node_id).first
						
						if log_global.nil?
							log_global = LogGlobalQuery.create(:queries_date => today, :resource => resource, :node_id => node_id)
						end

						log_global_id = log_global.id
		
						#LogZoneQuery.increment_counter(:invalid_hosts_count, log_global_id)
		
						log_total_global = LogTotalGlobalQuery.where(:log_date => today, :resource => resource, :node_id => node_id).first				

						if log_total_global.nil?
							log_total_global = LogTotalGlobalQuery.create(:log_date => today, :resource => resource, :node_id => node_id)
						end
		
						log_total_global_id = log_total_global.id
		
						if db_date_time > Time.new(today_year,today_month,today_day,0,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_1_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,1,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_2_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,2,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_3_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,3,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_4_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,4,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_5_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,5,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_6_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,6,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_7_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,7,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_8_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,8,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_9_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,9,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_10_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,10,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_11_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,11,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_12_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,12,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_13_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,13,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_14_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,14,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_15_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,15,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_16_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,16,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_17_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,17,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_18_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,18,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_19_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,19,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_20_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,20,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_21_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,21,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_22_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,22,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_23_count, log_total_global_id)
						elsif db_date_time > Time.new(today_year,today_month,today_day,23,0,0).strftime("%Y-%m-%d %H:%M:%S") && db_date_time <= Time.new(today_year,today_month,today_day,24,0,0).strftime("%Y-%m-%d %H:%M:%S")
							LogTotalGlobalQuery.increment_counter(:log_24_count, log_total_global_id)
						end
					#end global
					
			        unless ["reserve1", "reserve2"].include?resource
			        #LogQuery(mysql) or Query(mongo)	
			        LogQuery.create(:date_time => db_date_time,
			        				:client => client,
			        				:port => port,
			        				:host_id => host_id,
			        				:zone_id => zone_id,
			        				:view => view,
			        				:query => query,
			        				:resource => resource,
			        				:flag => flag,
			        				:interface => interface,
			        				:log_zone_query_id => log_zone_id,
			        				:log_host_query_id => log_host_id,
			        				:log_global_query_id => log_global_id  
			        				)
			        	log_ip_db = LogIp.where(:zone_id => zone_id, :host_id => host_id, :log_date => today, :ip => client, :node_id => node_id).first
			        	if log_ip_db.nil?
			        		log_ip_db = LogIp.create(:zone_id => zone_id, :host_id => host_id, :log_date => today, :ip => client, :hits_count => 0, :node_id => node_id)
			    		end
			    		
			    		LogIp.increment_counter(:hits_count, log_ip_db.id)
		
			    		log_country = log_ip_db.log_country
			    		unless log_country.nil?
				    		log_country_count = LogCountryCount.where(:zone_id => zone_id, :host_id => host_id, 
				    		                               :log_date => today, :log_country_id => log_country.id, 
				    		                               :node_id => node_id).first
				    		unless log_country_count.nil?
				    			LogCountryCount.increment_counter(:queries_count, log_country_count.id)
				    		end
			    		end
			        end
			    end
			  end
		    File.open(query_log, 'w') {|f| f.write("") }
	  		Dnscell::Rndc.new.reload_production
		 end
	rescue Exception => e
		puts e.message 
		sleep 60
		retry
	end
  sleep 10
end
