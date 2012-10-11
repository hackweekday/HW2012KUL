class NodesController < ApplicationController
	  set_tab :appliance_management
  	set_tab :nodes, :first_level
    set_tab :secondary, :first_level, :only => %w(index node_requests slave nodes_ls_slave zone_graph slave global_graph host_graph)
    set_tab :nodes_ls_slave, :second_level, :only => %w(nodes_ls_slave)
    set_tab :node_requests, :second_level, :only => %w(node_requests)
    set_tab :primary, :first_level, :only => %w(nodes_ls_primary primary)
    set_tab :nodes_ls_primary, :second_level, :only => %w(nodes_ls_primary)

    set_tab :messages, :first_level, :only => %w(messages)
    set_tab :general, :first_level, :only => %w(general)

    set_tab :information, :slave_menu, :only => %w(slave)
    set_tab :graph, :slave_menu, :only => %w(zone_graph global_graph host_graph)

    set_tab :zone_graph, :graph_scope, :only => %w(zone_graph)

    set_tab :global_graph, :graph_scope, :only => %w(global_graph)


    def log_date
      z = Zone.find_by_zone_name(params[:zone_name])
      if z
        if z.log_zone_queries
          render :json => { 
            "status" => "ok",
            "dates" => z.log_zone_queries.where(:node_id => 1).order("queries_date asc").group_by(&:queries_date).keys.map{|x| x.to_s}
          }
        else
          render :json => { "status" => "no_log" }
        end
      else
        render :json => { "status" => "zone_not_available" }
      end
    end

    def log_ip_transfer
      z = Zone.find_by_zone_name(params[:zone_name])
      @log_ips = LogIp.select("log_date, zone_id, host_id, ip, sum(hits_count) as hits_count, created_at, updated_at").where("node_id = 1 and log_date = ? and zone_id = ? and zone_id is not null", params[:queries_date], z.id).group("ip").paginate(:page => params[:page], :per_page => LOG_IP_PER_REQUEST)
      render :json => {
          "per_request" => LOG_IP_PER_REQUEST,
          "log_ips" => @log_ips.map{|x|
            [
              x.log_date,
              if x.zone_id.nil? then "nil" else begin Zone.find(x.zone_id).zone_name rescue "Unkown zone" end end,
              if x.host_id.nil? then "nil" else begin Host.find(x.host_id).combine rescue "Unkown host" end end,
              x.ip,
              x.hits_count,
              x.created_at,
              x.updated_at
            ]
          }
        }
    end

    def log_transfer_by_date
      z = Zone.find_by_zone_name(params[:zone_name])
      if z.nil?
        render :json => " sorry zone is not available "
      else
        tmp = LogZoneQuery.where("node_id = 1 and queries_date = ? and zone_id = ? and zone_id is not null", params[:queries_date], z.id)
        tmp2 = LogTotalZoneQuery.select("
          log_date,
          sum(log_1_count) as log_1_count, 
          sum(log_2_count) as log_2_count, 
          sum(log_3_count) as log_3_count, 
          sum(log_4_count) as log_4_count, 
          sum(log_5_count) as log_5_count, 
          sum(log_6_count) as log_6_count, 
          sum(log_7_count) as log_7_count, 
          sum(log_8_count) as log_8_count, 
          sum(log_9_count) as log_9_count, 
          sum(log_10_count) as log_10_count, 
          sum(log_11_count) as log_11_count, 
          sum(log_12_count) as log_12_count, 
          sum(log_13_count) as log_13_count, 
          sum(log_14_count) as log_14_count, 
          sum(log_15_count) as log_15_count, 
          sum(log_16_count) as log_16_count, 
          sum(log_17_count) as log_17_count, 
          sum(log_18_count) as log_18_count, 
          sum(log_19_count) as log_19_count, 
          sum(log_20_count) as log_20_count, 
          sum(log_21_count) as log_21_count, 
          sum(log_22_count) as log_22_count, 
          sum(log_23_count) as log_23_count, 
          sum(log_24_count) as log_24_count,
          created_at,
          updated_at,
          resource
          ").group(:resource).where("node_id = 1 and log_date = ? and zone_id = ?", params[:queries_date], z.id)
        tmp3 = LogCountryCount.select("zone_id, host_id, updated_at, created_at, log_date, country_code, sum(queries_count) as queries_count").group("country_code").where("node_id = 1 and log_date = ? and zone_id = ? and zone_id is not null", params[:queries_date], z.id).order("queries_count desc")
        log_ips = LogIp.where("node_id = 1 and log_date = ? and zone_id = ? and zone_id is not null", params[:queries_date], z.id)
        if log_ips.count < LOG_IP_PER_REQUEST
          tmp4 = LogIp.select("log_date, zone_id, host_id, ip, sum(hits_count) as hits_count, created_at, updated_at").where("node_id = 1 and log_date = ? and zone_id = ? and zone_id is not null", params[:queries_date], z.id).group("ip")
        else
          tmp4 = []
        end
        host_id_array = z.hosts.map{|x| x.id }
        tmp5 = LogHostQuery.find_all_by_host_id_and_queries_date(host_id_array, params[:queries_date])
        tmp6 = LogTotalHostQuery.find_all_by_host_id_and_log_date(host_id_array, params[:queries_date])
        date_yesterday = (params[:queries_date].to_date-1).to_s
        temp7 = LogZoneQuery.where("node_id = 1 and queries_date = ? and zone_id = ?", date_yesterday, z.id).order("updated_at desc").first
        temp7 = temp7.updated_at if temp7
        global_temp = LogGlobalQuery.where("node_id = 1 and queries_date = ? ", params[:queries_date])
        global_temp2 = LogTotalGlobalQuery.where("node_id = 1 and log_date = ?", params[:queries_date])

        render :json => { 
          "log_zone_queries" => tmp.map{|x| [x.queries_date, z.zone_name, x.queries_count, x.created_at, x.updated_at, x.resource]} ,
          "log_total_zone_queries" => tmp2.map{|x|
            [
              x.log_date,
              z.zone_name,
              x.log_1_count,
              x.log_2_count,
              x.log_3_count,
              x.log_4_count,
              x.log_5_count,
              x.log_6_count,
              x.log_7_count,
              x.log_8_count,
              x.log_9_count,
              x.log_10_count,
              x.log_11_count,
              x.log_12_count,
              x.log_13_count,
              x.log_14_count,
              x.log_15_count,
              x.log_16_count,
              x.log_17_count,
              x.log_18_count,
              x.log_19_count,
              x.log_20_count,
              x.log_21_count,
              x.log_22_count,
              x.log_23_count,
              x.log_24_count,
              x.created_at,
              x.updated_at,
              x.resource,
            ]
          },
          "log_country_counts" => tmp3.map{|x|
            [
              x.log_date,
              if x.zone_id.nil? or x.zone_id.blank? then "nil" else begin Zone.find(x.zone_id).zone_name rescue "Unkown zone" end end,
              if x.host_id.nil? or x.host_id.blank? then "nil" else begin Host.find(x.host_id).combine rescue "Unkown host" end end,
              x.country_code,
              x.queries_count,
              x.created_at,
              x.updated_at
            ]
          },
          "log_ip_per_request" => LOG_IP_PER_REQUEST,
          "log_ips_count" => log_ips.count,
          "log_ips" => tmp4.map{|x|
            [
              x.log_date,
              if x.zone_id.nil? then "nil" else begin Zone.find(x.zone_id).zone_name rescue "Unkown zone" end end,
              if x.host_id.nil? then "nil" else begin Host.find(x.host_id).combine rescue "Unkown host" end end,
              x.ip,
              x.hits_count,
              x.created_at,
              x.updated_at
            ]
          },
          "log_host_queries" => tmp5.map{|x|
            [
              x.queries_date, 
              if x.host_id.nil? then "nil" else begin Host.find(x.host_id).combine rescue "Unkown host" end end,
              x.queries_count, 
              x.created_at, 
              x.updated_at, 
              x.resource
            ]
          },
          "log_total_host_queries" => tmp6.map{|x|
            [
              x.log_date,
              if x.host_id.nil? then "nil" else begin Host.find(x.host_id).combine rescue "Unkown host" end end,
              x.log_1_count,
              x.log_2_count,
              x.log_3_count,
              x.log_4_count,
              x.log_5_count,
              x.log_6_count,
              x.log_7_count,
              x.log_8_count,
              x.log_9_count,
              x.log_10_count,
              x.log_11_count,
              x.log_12_count,
              x.log_13_count,
              x.log_14_count,
              x.log_15_count,
              x.log_16_count,
              x.log_17_count,
              x.log_18_count,
              x.log_19_count,
              x.log_20_count,
              x.log_21_count,
              x.log_22_count,
              x.log_23_count,
              x.log_24_count,
              x.created_at,
              x.updated_at,
              x.resource,
            ]
          },
          "yesterday_latest_updated_time" => temp7,
          "log_global_queries" => global_temp.map{|x| 
            [
              x.queries_date,
              x.queries_count, 
              x.created_at, 
              x.updated_at, 
              x.resource
            ]
          },
          "log_total_global_queries" => global_temp2.map{|x| 
            [
              x.log_date,
              x.log_1_count,
              x.log_2_count,
              x.log_3_count,
              x.log_4_count,
              x.log_5_count,
              x.log_6_count,
              x.log_7_count,
              x.log_8_count,
              x.log_9_count,
              x.log_10_count,
              x.log_11_count,
              x.log_12_count,
              x.log_13_count,
              x.log_14_count,
              x.log_15_count,
              x.log_16_count,
              x.log_17_count,
              x.log_18_count,
              x.log_19_count,
              x.log_20_count,
              x.log_21_count,
              x.log_22_count,
              x.log_23_count,
              x.log_24_count,
              x.created_at,
              x.updated_at,
              x.resource,
            ]
          }
        }
      end
    end

    def zone_graph
      get_node
      TmpZone.destroy_all  # del table from dis line
      temp = HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_zone_request?auth_token=#{@node.auth_token}").response.body
      node_zones = JSON.parse temp
      logger.debug "$$node_zones #{node_zones}"
      @zone = domain2url(node_zones.first)
      @zones = node_zones
    end

    def host_graph
      get_node
      temp = HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_zone_host_request?auth_token=#{@node.auth_token}").response.body
      @zone_host = JSON.parse temp
    end

    def global_graph
      get_node
    end

    def global_queries
      get_node
      params.delete :id
      zone_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=query&id=#{params[:zone_id]}&type=global&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      @table_content = zone_queries_var["table_content"]
      logger.debug "%%%%table_content #{@table_content}"
      @space = zone_queries_var["space"]
      @year = zone_queries_var["year"]
      @day = zone_queries_var["day"]
      @month = zone_queries_var["month"]
      @dif = zone_queries_var["dif"]
      @from = zone_queries_var["from"]
      @to = zone_queries_var["to"]
      params[:id] = params[:zone_id]
      render 'graph/global_queries.js'
    end

    def global_ip
      get_node
      params.delete :id
      zone_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=ip&type=global&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      @ip_table = zone_queries_var["ip_table"]
      logger.debug "$$$@ip_table #{@ip_table}"
      params[:id] = params[:zone_id]
      render 'graph/global_ip.js'
    end

    def global_country
      get_node
      params.delete :id
      zone_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=country&type=global&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      @country_table = zone_queries_var["country_table"]
      params[:id] = params[:zone_id]
      render 'graph/global_country.js'
    end

    def zone_queries
      get_node
      params.delete :id
      zone_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=query&id=#{params[:zone_id]}&type=zone&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      logger.debug "&&& #{zone_queries_var}"
      @table_content = zone_queries_var["table_content"]
      @space = zone_queries_var["space"]
      @year = zone_queries_var["year"]
      @day = zone_queries_var["day"]
      @month = zone_queries_var["month"]
      @dif = zone_queries_var["dif"]
      @from = zone_queries_var["from"]
      @to = zone_queries_var["to"]
      params[:id] = params[:zone_id]
      render 'graph/zone_queries.js'
    end

    def zone_ip
      get_node
      params.delete :id
      zone_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=ip&id=#{params[:zone_id]}&type=zone&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      @ip_table = zone_queries_var["ip_table"]
      logger.debug "$$$@ip_table #{@ip_table}"
      params[:id] = params[:zone_id]
      render 'graph/zone_ip.js'
    end

    def zone_country
      get_node
      params.delete :id
      zone_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=country&id=#{params[:zone_id]}&type=zone&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      @country_table = zone_queries_var["country_table"]
      params[:id] = params[:zone_id]
      render 'graph/zone_country.js'
    end

 def host_queries
      get_node
      params.delete :id
      host_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=query&id=#{params[:host_id]}&type=host&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      logger.debug "&&& #{host_queries_var}"
      @table_content = host_queries_var["table_content"]
      @space = host_queries_var["space"]
      @year = host_queries_var["year"]
      @day = host_queries_var["day"]
      @month = host_queries_var["month"]
      @dif = host_queries_var["dif"]
      @from = host_queries_var["from"]
      @to = host_queries_var["to"]
      params[:id] = params[:host_id]
      render 'graph/host_queries.js'
    end

    def host_ip
      get_node
      params.delete :id
      host_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=ip&id=#{params[:host_id]}&type=host&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      @ip_table = host_queries_var["ip_table"]
      logger.debug "$$$@ip_table #{@ip_table}"
      params[:id] = params[:host_id]
      render 'graph/host_ips.js'
    end

    def host_country
      get_node
      params.delete :id
      host_queries_var = JSON.parse HTTParty.get("http://#{@node.ip_address}:#{NODE_PORT_TWO}/reports/graph/node_request.json?query=country&id=#{params[:host_id]}&type=host&auth_token=#{@node.auth_token}&" + params.to_query).response.body
      @country_table = host_queries_var["country_table"]
      params[:id] = params[:host_id]
      render 'graph/host_countries.js'
    end

    def index
      redirect_to general_nodes_path
    end

    def general
      @node = Node.find_by_node_type("local")
    end

    def primary
      @node = Node.find(params[:id])
    end

    def delete_messages
      params[:msg_ids].split(",").each do |m|
        message = NodeMessage.find(m)
        message.destroy
      end
      render :js => "$('#dttb_message').dataTable().fnDraw(false);"
    end

    def get_paginated_messages
      case params[:iSortCol_0]
      when "0"
        sort_variable = "created_at desc"
      when "3"
        sort_variable = "created_at #{params[:sSortDir_0]}"
      end
        @messages = NodeMessage.where("message like ? AND received_or_sent = ?", "%#{params[:sSearch]}%", "#{params[:display_type].to_i}" ).order("notified").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
    end

    def slave
      get_node
    end


    def node_requests
      Node.where("notify = 0 AND registered is NOT null").update_all(:notify => 1)
    end

    def nodes_ls_primary
    end

    def nodes_ls_slave
    end

    def edit
      @node = Node.find(params[:id])
    end

    def destroy
      node = Node.find(params[:id])
      node.destroy
      render :js => "$('.dataTable').dataTable().fnDraw(false)"
    end


    def update
      node = Node.find(params[:id])
      if node.update_attributes(params[:node])
        render :js => "$('#node_ls_dttb_#{params[:display_type]}').dataTable().fnDraw(false);$('#node_form').dialog('close')"
      else
        render :js => "alert('error #{node.errors.full_messages}')"
      end
    end

    def get_paginated_nodes
    case params[:iSortCol_0]
    when "0"
      sort_variable = "created_at desc"
    when "3"
      sort_variable = "created_at #{params[:sSortDir_0]}"
    end
      case params[:display_type]
      when "0"
        nodes_query sort_variable
        render 'new_paginated_nodes.json'
      when "1"
        nodes_query sort_variable
        render 'nodes/nodes_ls'
      when "primary"
        @nodes = Node.where("node_type = 'primary'").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
        render 'nodes/nodes_ls'
      end
    end

    def nodes_query sort_variable
      @nodes = Node.where("node_type != 'local' AND node_type != 'primary' AND status = ?", "#{params[:display_type]}").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
    end

    def get_new_node_pairing_request_count
      new_node = Node.where("notify = 0 and registered is NOT null")
      render :json => { "new_node_count" => "#{new_node.count}" }
    end

    def get_unnotified_messages_count
      messages = NodeMessage.where(:notified => false)
      render :json => { "messages_count" => "#{messages.count}" }
    end

    def process_request 
      node = Node.find(params[:node_id])

      check = NodeCheck.new(:ip_address => node.ip_address, :node_serial => node.node_serial, :auth_token => node.auth_token)
      if check.valid?          
          #Rails.logger.auto_flushing = true
          #Rails.logger.info "#{response.body} at #{Time.now}.\n"

          # if node.status == 2
            # node.destroy
            # render :js => "show_flash('Node has been rejected.');$('#my_error_msg').remove();$('#node_request_dttb').dataTable().fnDraw(false)"
          # else
          # end
          # node.update_attributes(:status => params[:process_type], :validate => false)
          # Do approved node request here.
          # render :js => "alert('#{params[:node_id]} #{params[:process_type]}')"

            #communicate with node of the process
            n = Node.where(:node_type => "local").first
            n.remote_id = params[:node_id]
            n.id = node.remote_id
            n.status = params[:process_type]
            ActiveRecord::Base.include_root_in_json = true
            url = "http://#{node.ip_address}:#{NODE_PORT_TWO}/api/v1/nodes/result.json?auth_token=#{node.auth_token}"
            response = Typhoeus::Request.post(url, :params => {:json => n.to_json(:except => [ :node_type, :last_seen, :node_name, :created_at, :updated_at ] ) } )

          if params[:process_type] == "1"
            node.status = params[:process_type]
            node.save(:validate => false)
            render :js => "show_flash('Node has been approved.');$('#my_error_msg').remove();$('#node_request_dttb').dataTable().fnDraw(false)"
          elsif params[:process_type] == "2"
            node.destroy
            render :js => "show_flash('Node has been rejected.');$('#my_error_msg').remove();$('#node_request_dttb').dataTable().fnDraw(false)"
          end
      else
          logger.debug "&&&& not valid"
           @errors = []
           check.errors.each {|x| @errors << check.errors[x]}
           render 'hosts/create_error.js'
      end
    end

  	def new
  		@node = Node.new
  	end

  	def create
  		@node = Node.new(params[:node])
      @node.node_type = "primary"
      @node.node_name = @node.ip_address
  		if @node.save
  			# redirect_to nodes_path, :notice => "Node has been register and waiting for approval"
        render :js => "$('#node_form').dialog('close');show_flash('Node has been register and waiting for approval');$('.dataTable').dataTable().fnDraw()"
  		else
  			render 'new'
  		end

  	end

    def get_node
      @node = Node.find(params[:id])
    end
end
