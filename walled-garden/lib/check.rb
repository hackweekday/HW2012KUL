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
  
  # Replace this with your code
  #Rails.logger.auto_flushing = true
  #Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  #http://rubydoc.info/gems/dnsruby/1.52/Dnsruby/RR/
  hosts = Host.where(:subdomain => "@") 

  hosts.each do |host|
    if host.zone.nil?
      puts "#{host.combine}: zone dah kena delete"
      Host.destroy_all(:zone_id => host.zone_id)
      ZoneUtils.delete_zone host.combine, host.user.id
    end
  end

  #exit
  
  sleep 60*15
end
