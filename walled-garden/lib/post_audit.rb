#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
#ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  if Utils.check_ssh_rndc?
    # Replace this with your code
    #Rails.logger.auto_flushing = true
    #Rails.logger.info "This daemon is still running at #{Time.now}.\n"
    #http://rubydoc.info/gems/dnsruby/1.52/Dnsruby/RR/

    #Check zone_current_status.

    zones = ZoneStatus.where(:zone_status => true)

    zones.each do |zone|
      if zone.created_at < 2.days.ago
        zone.last_checked_at = Time.now
        zone.save( :validate => false )

        nservers = Array.new
        dnscell_ns = Array.new
        znss = ZoneNameServer.where(:zone_id => zone.id)
        
        unless znss.empty?
          znss.each do |zns|
            #dnscell_ns = ["a.dnscell.com", "b.dnscell.com"] 
            dnscell_ns << zns.ns
          end
        else
            dnscell_ns = ["a.dnssocial.com", "b.dnssocial.com"] 
        end

        puts "List of ns #{dnscell_ns}"
        
        begin
          #Dnsruby::DNS.open {|dns|
          # dns.each_resource(zone.zone_name, "NS") {|rr| nservers << rr}
          #}
          dir = Rails.root.join("lib")
          data = %x{perl #{dir}/ns-test1.pl #{zone.zone_name} }.split("\n")
          puts zone.zone_name
          puts data
          if data.kind_of?(Array)
            unless data.count < 2
              data.each do |d|
                puts d
                ns = d.split("\t")[4]
                puts ns
                nservers << ns.split(".").join(".")
              end
            end
            puts "data is not empty"
          else
            puts "data is empty"
          end
        rescue Exception => e 
          puts e.message
          #if zone.created_at < 3.days.ago
          #    User.decrement_counter(:current_domains_count, zone.user.id)
          #    UserMailer.delay.not_verified_domain(zone.user, zone.zone_name)
          #    ZoneUtils.delay.delete_zone zone.zone_name, zone.user.id
          #    zone.destroy
          # end
        end
        
        nservers.each do |ns|
          #puts ns.rdata
          #if dnscell_ns.include?ns.rdata.to_s
          puts "Dalam nservers utk include #{ns}"
          if dnscell_ns.include?ns
             t = eval('["#{ns}"]')
             dnscell_ns = dnscell_ns - eval('["#{ns}"]')
             puts "eval #{t}"
          end
        end
        
        if dnscell_ns.empty?
           #zone.update_attributes(:zone_status => true, :zone_current_status => true)
           #zone.zone_status = true

          #get into block if only the zone current status is false
          unless zone.zone_current_status
             zone.last_active = Time.now
             zone.zone_current_status = true
             zone.save(:validate => false)
             UserMailer.delay.back_active_domain(zone.user, zone)
             
             SystemAudit.create(:user_id => zone.user_id, :zone_id=> zone.id, 
              :label => "zone", :message => "Domain #{zone.zone_name} is active",
              :zone_name => zone.zone_name, :host_name => zone.zone_name, 
              :reference => zone.zone_name, :action => "recheck_zone_set_to_true", :system => true,
              :code => 403)

             puts "zone.zone_name is now active"
          end
        else
           unless zone.last_inactive.blank?
             if zone.last_inactive < 2.weeks.ago 
                User.decrement_counter(:current_domains_count, zone.user.id)

                UserMailer.delay.not_verified_domain(zone.user, zone.zone_name)
                
                Host.destroy_all(:zone_id => zone.id)
                
                ZoneUtils.delete_zone zone.zone_name, zone.user.id
                
                SystemAudit.create(:user_id => zone.user_id, :zone_id=> zone.id, 
                :label => "zone", :message => "Destroying #{zone.zone_name} because the domain is not active",
                :zone_name => zone.zone_name, :host_name => zone.zone_name, 
                :reference => zone.zone_name, :action => "destroy_not_active_zone", :system => true,
                :code => 404)

                zone.destroy
                puts "Destroying #{zone.zone_name} because the domain is not active"
             else
                #set the flag dude
                if zone.zone_current_status
                  zone.last_inactive = Time.now
                  zone.zone_current_status = false
                  zone.save(:validate => false)

                  UserMailer.delay.inactive_domain(zone.user, zone)
                 
                  SystemAudit.create(:user_id => zone.user_id, :zone_id=> zone.id, 
                    :label => "zone", :message => "Domain #{zone.zone_name} is not active",
                    :zone_name => zone.zone_name, :host_name => zone.zone_name, 
                    :reference => zone.zone_name, :action => "recheck_zone_set_to_false", :system => true,
                    :code => 402)

                  puts "zone.zone_name is not active"
                end
              end
            else
              if zone.zone_current_status
                  zone.last_inactive = Time.now
                  zone.zone_current_status = false
                  zone.save(:validate => false)

                  UserMailer.delay.inactive_domain(zone.user, zone)
                 
                  SystemAudit.create(:user_id => zone.user_id, :zone_id=> zone.id, 
                    :label => "zone", :message => "Domain #{zone.zone_name} is not active",
                    :zone_name => zone.zone_name, :host_name => zone.zone_name, 
                    :reference => zone.zone_name, :action => "recheck_zone_set_to_false", :system => true,
                    :code => 402)

                  puts "zone.zone_name is not active"
                end
              
            end
           puts "betul"
           puts "last line #{dnscell_ns}"
           puts zone.created_at
           puts 1.days.ago
           #zone.update_attributes(:zone_status => false)
        end 
      end
    end
  else
    puts "connection lost dude!"
  end #of utils_check
    #exit
  
  sleep 60*60
end
