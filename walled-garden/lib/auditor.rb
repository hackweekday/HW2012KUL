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
  zones = ZoneStatus.where(:audit_ns => false)
  zones.each do |zone|
    #pass the audit set the audit_ns to true
    result = true
    dnssocial_com = Utils.get_soa_boolean(zone.zone_name, "202.171.45.208")
    a_dnssocial_com = Utils.get_soa_boolean(zone.zone_name, "198.101.192.71")
    b_dnssocial_com = Utils.get_soa_boolean(zone.zone_name, "23.23.193.129")

    name_servers = Array.new

    unless dnssocial_com 
      name_servers << "dnssocial.com"
      result = false
    end

    unless a_dnssocial_com 
      name_servers << "a.dnssocial.com"
      result = false
    end

    unless b_dnssocial_com 
      name_servers << "b.dnssocial.com"
      result = false
    end


    if result
      zone.audit_ns = true
      zone.save(:validate => false)
    else
      puts zone.zone_name
      unless zone.audit_ns_report
        #send email to admin only once
        UserMailer.delay.audit_zone_problem("support@dnssocial.com", zone, name_servers)
        zone.audit_ns_report = true
        zone.save(:validate => false)
      end
    end

  end
  puts "Done, sleeping"
  sleep 60*30
end
