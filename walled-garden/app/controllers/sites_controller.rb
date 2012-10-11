class SitesController < ApplicationController

	def index
		#This fetch domain and subdomain
    require 'open-uri'
    require 'json'


    #Remote IP
    @rip = request.remote_addr
    

		if request.subdomain.empty?
        	host_data = request.domain
   	else
      	host_data = "#{request.subdomain }.#{request.domain}"
   	end

   	#Get subscriber ID
   	@sid = request.subdomain.split(".")[-1]
   	#Get URL
   	@url = request.subdomain.split(".")[0..-2].join(".")

   	#Geo
   	geo = GeoIP.new("#{Rails.root.to_s}/../GeoLiteCity.dat")
   	g = geo.country(request.remote_addr)

   	if g.nil?
    	country = state  = nil
   	else
     	country = g[4]
     	state = g[7]
   	end

   	browser, version = harvest_browser(request.user_agent)

   	remote_host = request.remote_host
   	server_name = request.server_name
   	referer = request.referer

     	#render :text => "#{request.subdomain} #{request.domain}"
   	@result =  "Subscriber ID: #{@sid} URL: #{@url} RIP: #{@rip} Country: #{country} State: #{state} Browser: #{browser} BVersion: #{version} remote_host: #{remote_host} server_name: #{server_name} referer: #{referer}"

    

    sb = Subscriber.find_by_sid(@sid)
    if sb.nil?
      sb = Subscriber.create(:sid => @sid)
    end

    addr = IpAddress.find_by_address(@rip)

    if addr.nil?
      @ipdb= "http://api.db-ip.com/addrinfo?addr=#{@rip}&api_key=b444a199c1185cb044c5cf8306451d990a6531ac"
      @json_object = JSON.parse(open(@ipdb).read)
      ip_hash = JSON.parse @json_object.to_json
      addr = IpAddress.create(ip_hash)
    end

    DataSeed.create(:subscriber_id => sb.id , :ip_address_id => addr.id,  :url => @url, 
      :rip => @rip, :browser => browser, 
      :browser_version => version, :agent => request.user_agent )

    #redirect_to "http://save.rpzwg.org/"
    #DataSilo.create(:sid => @sid, :url => @url, 
    #          :rip => @rip, :country => country, 
    #          :state => state, :browser => browser, 
    #          :browser_version => version, :agent => request.user_agent )
	end

	def index2
		#This fetch domain and subdomain
		if request.subdomain.empty?
        	host_data = request.domain
     	else
        	host_data = "#{request.subdomain }.#{request.domain}"
     	end

     	f = Forward.where(:host_data => host_data).first

     	if f.nil?
        	redirect_to "http://www.dnssocial.com"
     	else
       		geo = GeoIP.new("#{Rails.root.to_s}/../GeoLiteCity.dat")
       		g = geo.country(request.remote_addr)
       	end

       	if g.nil?
        	country = state  = "unknown"
       	else
         	country = g[4]
         	state = g[7]
       	end

       	#histories
       	remote_addr = request.remote_addr
       	#user_agent = request.user_agent
       	#user_agent = request.env['HTTP_REFERER']
       	user_agent_check = harvest_browser(request.user_agent)
       	user_agent  = "#{user_agent_check[0]} #{user_agent_check[1]}"
       	remote_host = request.remote_host
       	server_name = request.server_name
       	referer = request.referer

       	f.forward_histories.build(:remote_addr => remote_addr, :user_agent => user_agent, :remote_host => remote_host, :server_name => server_name, :referer => referer, :country => country, :state => state)

       	f.save

       	if f.hits.nil?
           hits = 1
        else
           hits = f.hits + 1
        end
         
        f.update_attributes(:hits => hits )

        unless f.stealth 
          redirect_to f.destination
        else  
          @title = f.title
          @meta_keywords = f.meta_keywords
          @meta_descriptions = f.meta_discription
          @destination = f.destination
          render 'stealth'
        end
	end

	def harvest_browser(user_agent)
    	if user_agent.downcase =~ %r{(#{ ["chrome", "shiira", "safari", "netscape", "epiphany", "flock", "firefox", "camino", "chimera", "galeon", "icab", "contiki", "curl", "democracy",  "opera", "webtv", "rockmelt", "msie"].map{|s| Regexp.escape(s)}.join('|')})/(\S+)}
      		browser = $1
      		version = $2
    	else
      		browser = "unknown"
      		version = "unknown"
    	end
    	browser_info = [browser, version]
  	end

end
