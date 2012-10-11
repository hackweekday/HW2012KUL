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
  #users = User.where(:email => "amir@localhost.my")
  users = User.all

  users.each do |u|
    #current_domains_count
    #current_hosts_count
    puts u.email
    UserMailer.delay.update_soa(u)
    sleep ( 3+Random.rand(11) )
  end


  #exit
  
  exit
  #sleep 60*5
end
