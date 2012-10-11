class NamedLogsController < ApplicationController
	set_tab :named_logs, :first_level
	def index

	end

	def get_paginated_data
	case params[:iSortCol_0]
	when "0"
		sort_variable = "date_time #{params[:sSortDir_0]}"
	when "1"
		sort_variable = "created_at desc"
	when "2"
		sort_variable = "created_at #{params[:sSortDir_0]}"
	end
		@logs = NamedLog.where("category like ? and severity like ? and (date_time like ? or log_message like ?)", "%#{params[:category]}%", "%#{params[:severity]}%", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
		@categories = NamedLog.select("category").group("category").map{|x| x.category }
		@severities = NamedLog.select("severity").group("severity").map{|x| x.severity }
		logger.debug "@@@@ #{@severities} #{@categories}"
		@logs_count = @logs.count
	  # @nodes = @zone.nodes.where("node_name LIKE ? AND node_type = '#{node_type}'", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
	  # @unassigned_nodes = @zone.zone_nodes.empty? ? Node.where("status = 1 AND node_type = 'secondary'") : Node.where("status = 1 AND node_type = 'secondary' AND id not in (?)", @zone.zone_nodes.map{|zn| zn.node_id })
	  # logger.debug "** #{@zone.zone_nodes.map{|zn| zn.node_id}}"
	end

end
