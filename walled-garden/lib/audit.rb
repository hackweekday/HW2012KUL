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
    zones = ZoneStatus.where(:zone_status => false)
    zones.each do |zone|
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
         zone.last_active = Time.now
         zone.zone_status = true
         zone.zone_current_status = true
         zone.save(:validate => false)
         UserMailer.delay.verified_domain(zone.user, zone.zone_name)
         
         SystemAudit.create(:user_id => zone.user_id, :zone_id=> zone.id, 
          :label => "zone", :message => "Domain #{zone.zone_name} is verified",
          :zone_name => zone.zone_name, :host_name => zone.zone_name, 
          :reference => zone.zone_name, :action => "verified_zone", :system => true,
          :code => 400)

         puts "zone.zone_name is now verified"
      else
         if zone.created_at < 2.days.ago
            User.decrement_counter(:current_domains_count, zone.user.id)
            UserMailer.delay.not_verified_domain(zone.user, zone.zone_name)
            Host.destroy_all(:zone_id => zone.id)
            ZoneUtils.delete_zone zone.zone_name, zone.user.id
            SystemAudit.create(:user_id => zone.user_id, :zone_id=> zone.id, 
            :label => "zone", :message => "Destroying #{zone.zone_name} because the domain could not be verified",
            :zone_name => zone.zone_name, :host_name => zone.zone_name, 
            :reference => zone.zone_name, :action => "destroy_not_verified_zone", :system => true,
            :code => 401)
            zone.destroy
            puts "waa"
         end
         puts "betul"
         puts "last line #{dnscell_ns}"
         puts zone.created_at
         puts 1.days.ago
         #zone.update_attributes(:zone_status => false)
      end 
    end
  else
    puts "connection lost dude!"
  end #of utils_check
    #exit
  
  sleep 60*15
end
