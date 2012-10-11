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
  users = User.all

  users.each do |u|
    #current_domains_count
    #current_hosts_count
    assign = u.user_scopes.where(:assign_flag => true, :status => true).length
    current_zones = u.hosts.where(:typ => 0).length + assign
    current_hosts = Host.where(:quota_user_id => u.id).length

    puts u.email

    puts "#{u.current_domains_count} #{current_zones}"
    puts "#{u.current_hosts_count} #{current_hosts}"

    if u.current_domains_count != current_zones
      u.current_domains_count = current_zones
      u.save(:validate => false)
    end
      
    if u.current_hosts_count != current_hosts
      u.current_hosts_count = current_hosts
      u.save(:validate => false)
    end
    puts "======="
  end


  #exit
  
  sleep 60*5
end
