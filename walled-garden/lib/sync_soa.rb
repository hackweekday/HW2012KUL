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
  #First to check SOA 
  #case "mname"    { print $_->mname }
  #              case "rname"    { print $_->rname }
  #              case "serial"   { print $_->serial }
  #              case "refresh"  { print $_->refresh }
  #              case "retry"    { print $_->retry }
  #              case "expire"   { print $_->expire }
  #              case "minimum"  { print $_->minimum }
  zones = ZoneStatus.all

  zones.each do |z|
    mname, rname, serial, refresh, soa_retry, expire, minimum = Utils.get_soa_values(z.zone_name)
    puts mname
    current_sn = Utils.increase_soa_record z.id
    r = Record.where(:record_host => z.zone_name, :record_type => "SOA").first
    c = r.content.split
    puts c[2] 
    c[2] = current_sn.to_i + 1
    c[5] = "649000"
    puts c[2]
    result = c.join(" ")
    r.content = result
    r.save(:validate => false)
    rr = RecordUtils.new 1, z.id
    rr.create_common r
    rr.push_update
    puts result
    soa_content = Utils.increase_soa_record z.id    
    puts soa_content
  end

  sleep 60*5
end
