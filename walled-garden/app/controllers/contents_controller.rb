class ContentsController < ApplicationController
	set_tab :graph
	set_tab :zone, :first_level, :only => %w(zone)
	set_tab :ip, :first_level, :only => %w(ip)

	def index
		redirect_to :action => 'zone'
	end

	def zone
	end

	def zone_search
		@results = Record.where("rr_zone = ? AND rr_type like ? AND rr_host like ?", "#{params[:zone]}", "%#{params[:rr_type].gsub('All','')}%", "%#{params[:host].gsub('All','')}%")
		render :layout => false
	end

	def ip
	end

	def ip_search
		@results = Record.where("(rr_type = 'A' or rr_type = 'AAAA') AND rr_zone like ? AND data like ?", "%#{params[:zone].gsub('All','')}%", "%#{params[:ip].gsub('All','')}%")
		render :layout => false
	end
		

	def get_rr_type
		@rr_type = Record.select("rr_type").where(:rr_zone => params[:zone]).group("rr_type")
		logger.debug "#{@rr_type.to_a}"
	end
end
