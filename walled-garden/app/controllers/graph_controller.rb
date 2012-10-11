class GraphController < ApplicationController
	set_tab :graph
	set_tab :zone, :first_level, :only => %w(index zone zone_country zone_queries)
	set_tab :host, :first_level, :only => %w(hosts)
	set_tab :global, :first_level, :only => %w(global)
	set_tab :country, :first_level, :only => %w(country)
	set_tab :ip, :first_level, :only => %w(ip)
	set_tab :zone_country, :second_level, :only => %w(zone_country)
	set_tab :zone_queries, :second_level, :only => %w(zone_queries)
	set_tab :global_query, :second_level, :only => %w(global)


############# node communication

	def node_zone_request
		@zones = Zone.all
		render :json => @zones.map{|x| x.zone_name }
	end

	def node_zone_host_request
		@zones = Zone.all
		@zone_host = {}
		@zones.each do |z|
			@zone_host[z.zone_name] = z.hosts.map{|x| x.combine }
		end
		render :json => @zone_host
	end

	def node_request
		case params[:type] #global or zone
		when 'zone'
			case params[:query]
			when 'query'
				logger.debug "$$$ lalu query"
				zone_queries #zone_country #zone_ip
				temp = { 
					"table_content" => @table_content,
					"space" => @space,
					"year" => @year,
					"day" => @day,
					"month" => @month,
					"dif" => @dif,
					"from" => @from,
					"to" => @to
				}
			when 'ip'
				zone_ip
				temp = { 
					"ip_table" => @ip_table
				}
				logger.debug "$$$@ip_table #{@ip_table}"
			when 'country'			
				logger.debug "$$$ lalu country"
				zone_country
				temp = { 
					"country_table" => @country_table
				}
			end

			# render 'node_request.json'
			# zone_country
			# zone_ip

		when 'global'
			case params[:query]
			when 'query'
				logger.debug "$$$ lalu query"
				global_queries #zone_country #zone_ip
				temp = { 
					"table_content" => @table_content,
					"space" => @space,
					"year" => @year,
					"day" => @day,
					"month" => @month,
					"dif" => @dif,
					"from" => @from,
					"to" => @to
				}
				logger.debug "$$$@table_content #{@table_content}"
			when 'ip'
				global_ip
				temp = { 
					"ip_table" => @ip_table
				}
				logger.debug "$$$@ip_table #{@ip_table}"
			when 'country'			
				logger.debug "$$$ lalu country"
				global_country
				temp = { 
					"country_table" => @country_table
				}
			end
		
		when 'host'
			case params[:query]
			when 'query'
				logger.debug "$$$ lalu query"
				host_queries #zone_country #zone_ip
				temp = { 
					"table_content" => @table_content,
					"space" => @space,
					"year" => @year,
					"day" => @day,
					"month" => @month,
					"dif" => @dif,
					"from" => @from,
					"to" => @to
				}
				logger.debug "$$$@table_content #{@table_content}"
			when 'ip'
				host_ips
				temp = { 
					"ip_table" => @ip_table
				}
				logger.debug "$$$@ip_table #{@ip_table}"
			when 'country'			
				logger.debug "$$$ lalu country"
				host_countries
				temp = { 
					"country_table" => @country_table
				}
			end
		end

		render :json => temp
	end

############# end node communication

############# graph utils
	def check_node_status
		unless params[:id].nil?
			@zone = Zone.find_by_zone_name(url2domain(params[:id]))
			unless @zone.nodes.empty?
				@nodes = @zone.nodes
				@js = "node_menu('show')"
			else
				@nodes = @zone.nodes
				@js = "$('input.node').val(1);node_menu('hide')"
			end
		else
			@nodes = Node.where("id not in (1)")
		end

	end
############# graph utils end

############# host


	def host_queries
		logger.debug "host_queries start"
	    get_zones_and_zone params[:zone_id]
	    @host = Host.find_by_combine(url2domain(params[:host_id]))
	    @date = Date.today.to_s
	    @x = []
		@rr_type_a = []
		@rr_type_aaaa = []
		@rr_content = []
		@rr_type = []
		@rr = []
		if params[:start_date].nil? or params[:date].nil?
	    else
			query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
	    	if params[:search_option] == "day"
		    	s = params[:date].split("-")
		    	@year = s[0]
		    	@month = s[1]
		    	@day = s[2]
				@queries = @host.log_total_host_queries.select("sum(log_1_count) as sumlog1, sum(log_2_count) as sumlog2, sum(log_3_count) as sumlog3, sum(log_4_count) as sumlog4, sum(log_5_count) as sumlog5, sum(log_6_count) as sumlog6, sum(log_7_count) as sumlog7, sum(log_8_count) as sumlog8, sum(log_9_count) as sumlog9, sum(log_10_count) as sumlog10, sum(log_11_count) as sumlog11, sum(log_12_count) as sumlog12, sum(log_13_count) as sumlog13, sum(log_14_count) as sumlog14, sum(log_15_count) as sumlog15, sum(log_16_count) as sumlog16, sum(log_17_count) as sumlog17, sum(log_18_count) as sumlog18, sum(log_19_count) as sumlog19, sum(log_20_count) as sumlog20, sum(log_21_count) as sumlog21, sum(log_22_count) as sumlog22, sum(log_23_count) as sumlog23, sum(log_24_count) as sumlog24").where("log_date = ?", "#{params[:date]}").first
				@query = @host.log_total_host_queries.select("
					resource,
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
					sum(log_24_count) as log_24_count
					").group(:resource).where("log_date = ?", "#{params[:date]}").where("#{query_statement}")
				@rr_content = []
				@rr_type = @query.map{|x| x.resource }
				(0..23).each_with_index do |hour,hi|
						@rr_content[hi] = @query.map{|x| eval("x.log_#{hi+1}_count") }
				end
				@subtotal = []
				@query.each do |qry|
					sum = 0
					(0..23).each_with_index do |h,i|
						sum += eval("qry.log_#{i+1}_count")
					end
					@subtotal.push(sum)
				end
		    	# refactor begind
					setup_query_variable
				#refactor end

				
			elsif params[:search_option] == "range"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
		        f = @from.split("-")
		        t = @to.split("-")
		        @dif = (Time.new(t[0],t[1],t[2],0,0,0) - Time.new(f[0],f[1],f[2],0,0,0))/(60*60*24)
		        @val = Array.new
		        @queries = LogHostQuery.where("queries_date <= ? AND queries_date >= ?", @to, @from).where(:host_id => @host.id).where("#{query_statement}")
		        @rr_type = @host.log_host_queries.select("resource").where("(queries_date <= ? AND queries_date >= ?)", @to, @from).where("#{query_statement}").group("resource").map{|x| [x.resource]}
		        @rr = @host.log_host_queries.select("resource, queries_date, queries_count").where("(queries_date <= ? AND queries_date >= ?)", @to, @from).where("#{query_statement}")
		        @total_queries = []
		        @date_group = []
				@rr_content2 = []

		        if @dif.floor < 7
		          @space = 1
		        elsif @dif.floor < 12
		          @space = 4
		        elsif @dif.floor < 60
		          @space = 7
		        else
		          @space = 30
		        end

		        (0..@dif.floor).each do |x|
		            v = (Time.new(f[0],f[1],f[2],0,0,0)+x.day).strftime("%Y-%m-%d")
		            @date_group.push(v)
		            total_queries = 0
		            rr_type_a_queries_count = 0
		            rr_type_aaaa_queries_count = 0

		            @queries.each do |q|
		              @a = v
		              @b = q.queries_date
		              if v.to_s == q.queries_date.to_s
		                total_queries = q.queries_count + total_queries
		              end
		            end

		            vv = v.split("-")
					# subtotal = 0
		            @rr_type.each do |rr|
						queries_count = 0
		            	temp = @rr.find_all{|x| x.resource == rr[0]}
		            	unless temp.empty?
		            		temp.each do |tmp|
		            			if tmp.queries_date.to_s == v.to_s
		            				queries_count = tmp.queries_count
		            			end
		            		end
		            	end
		            	@rr_content.push([rr[0],"[Date.UTC(#{vv[0]}, (#{vv[1].to_i-1}), #{vv[2]}), #{queries_count}],"])
		            	@rr_content2.push([v, rr[0], queries_count])
		            	@total_queries.push(queries_count)
    				# subtotal += queries_count
		            end
		            @val.push("[Date.UTC(#{vv[0]}, (#{vv[1].to_i-1}), #{vv[2]}), #{total_queries}],")
		        end
				# refactoring variable for table begin
					setup_query_variable
				# refactoring variable for table end
		        @total_queries = @total_queries.inject(:+)
			end
	    end
	end

	def host_countries
	    get_zones_and_zone params[:zone_id]
		@host = Host.find_by_combine(url2domain(params[:host_id]))
		if params[:start_date].nil? or params[:date].nil?
			@countries = @host.log_country_counts.select("country_code, sum(queries_count) as query_sum").group("country_code").order("query_sum desc")
			@countries_count = @countries.length
			@countries = @countries.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
			@countries_sum = @host.log_country_counts.sum("queries_count")
	    else
			query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
	    	if params[:search_option] == "day"
				@countries = @host.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").group("country_code").order("query_sum desc")
				@countries_count = @countries.length
				@countries = @countries.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
				@countries_sum = @host.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").sum("queries_count")
				# refactor begins
					setup_country_variable
				# refactor end
			elsif params[:search_option] == "range"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
				@countries = @host.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").group("country_code").order("query_sum desc")
				@countries_count = @countries.length
				@countries = @countries.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
				@countries_sum = @host.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").sum("queries_count")
				# refactor begins
					setup_country_variable
				# refactor end	
			end
	    end
	end

	def host_ips
	    get_zones_and_zone params[:zone_id]
	    @host = Host.find_by_combine(url2domain(params[:host_id]))
	    if params[:start_date].nil? or params[:date].nil?
			@ips = @zone.log_ips.select("log_country_id, ip, sum(hits_count) as hits_sum").group("ip").order("hits_sum desc")
			@ips_count = @ips.length
			@ips = @ips.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
	    else
	    	query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
	    	if params[:search_option] == "day"
				@ips = @host.log_ips.select("log_country_id, ip, sum(hits_count) as hits_sum").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").group("ip").order("hits_sum desc")
				@ip_sum = @host.log_ips.select("log_country_id, ip").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").sum(:hits_count)
				@ips_count = @ips.length
				@ips = @ips.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
				# refactor begins
					setup_ip_variable
				# refactor end
			elsif params[:search_option] == "range"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
				@ips = @host.log_ips.select("log_country_id, ip, sum(hits_count) as hits_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").group("ip").order("hits_sum desc")
				@ip_sum = @host.log_ips.select("log_country_id, ip)").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").sum(:hits_count)
				@ips_count = @ips.length
				@ips = @ips.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
				# refactor begins
					setup_ip_variable
				# refactor end
			end
	    end

	end

	def host_search
		@zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
		if params[:string] == url2domain(params[:zone_id])
			@hosts = @zone.hosts.where("combine = ?", url2domain(params[:zone_id])).paginate(:page => params[:page].nil? ? 1 : params[:page], :per_page => 10)
		else
			@hosts = @zone.hosts.where("combine like ?", "%#{params[:string]}%").without_destroy_state.paginate(:page => params[:page].nil? ? 1 : params[:page], :per_page => 10)
		end
		render 'host.js'
	end

	def zone_search
		@zones = Zone.where("zone_name like ?", "%#{params[:q]}%").paginate(:per_page => 10, :page => params[:page])
		render 'zone_search.js'
	end


	def hosts
		@zones = Zone.all
		# prepare for refactor
			@zone_host = {}
			@zones.each do |z|
				@zone_host[z.zone_name] = ["All"]
				@zone_host[z.zone_name] += z.hosts.map{|x| x.combine }
			end
		# prepare for refactor end

		@zone = Zone.last
		@host = @zone.hosts.last
		@hosts = @zone.hosts
		if @host
			# redirect_to host_zone_host_graph_index_path(:host_id => domain2url(@host.combine), :zone_id => domain2url(@zone.zone_name))
		end
	end

	def host
		@zones = Zone.all
		@zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
		@hosts = @zone.hosts.without_destroy_state.paginate(:page => params[:page].nil? ? 1 : params[:page], :per_page => 10) if @zone.hosts

		if params[:host_id] 
			logger.debug "atas"
			@host = Host.find_by_combine(url2domain(params[:host_id]))
		else
			logger.debug "bawah"
			@host = @zone.hosts.first
			redirect_to host_zone_host_graph_index_path(:zone_id => domain2url(@zone.zone_name),:host_id => domain2url(@host.combine)) if @host
		end
	end

############# end host

	# def host_queries
	# end

	# def host_countries
	# end

	# def host_ips
	# end

	def global_queries
	    @date = Date.today.to_s
	    @x = []
		@rr_type_a = []
		@rr_type_aaaa = []
		@rr_content = []
		@rr_type = []
		@rr = []
		if params[:start_date].nil? or params[:date].nil?
	    	logger.debug "%%% 1"
	    	# @countries = @zone.log_country_counts.group("country_code")
	    else
	    	query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
	    	if params[:search_option] == "day"
		    	logger.debug "%%% 2"
		    	s = params[:date].split("-")
		    	@year = s[0]
		    	@month = s[1]
		    	@day = s[2]
				@queries = LogTotalGlobalQuery.select("sum(log_1_count) as sumlog1, sum(log_2_count) as sumlog2, sum(log_3_count) as sumlog3, sum(log_4_count) as sumlog4, sum(log_5_count) as sumlog5, sum(log_6_count) as sumlog6, sum(log_7_count) as sumlog7, sum(log_8_count) as sumlog8, sum(log_9_count) as sumlog9, sum(log_10_count) as sumlog10, sum(log_11_count) as sumlog11, sum(log_12_count) as sumlog12, sum(log_13_count) as sumlog13, sum(log_14_count) as sumlog14, sum(log_15_count) as sumlog15, sum(log_16_count) as sumlog16, sum(log_17_count) as sumlog17, sum(log_18_count) as sumlog18, sum(log_19_count) as sumlog19, sum(log_20_count) as sumlog20, sum(log_21_count) as sumlog21, sum(log_22_count) as sumlog22, sum(log_23_count) as sumlog23, sum(log_24_count) as sumlog24").where("log_date = ?", "#{params[:date]}").first
				# @query = LogTotalGlobalQuery.where("log_date = ?", "#{params[:date]}")
				@query = LogTotalGlobalQuery.select("
					resource,
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
					sum(log_24_count) as log_24_count
					").group(:resource).where("log_date = ?", "#{params[:date]}").where("#{query_statement}")
				#@query = LogTotalGlobalQuery.where("log_date = ?", "#{params[:date]}").group("resource")
				@rr_content = []
				@rr_type = @query.map{|x| x.resource }
				(0..23).each_with_index do |hour,hi|
						@rr_content[hi] = @query.map{|x| eval("x.log_#{hi+1}_count") }
				end
				@subtotal = []
				@query.each do |qry|
					sum = 0
					(0..23).each_with_index do |h,i|
						sum += eval("qry.log_#{i+1}_count")
					end
					@subtotal.push(sum)
				end

			# refactor begin 
				setup_query_variable
			# refactor end	

			elsif params[:search_option] == "range"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
		        f = @from.split("-")
		        t = @to.split("-")
		        @dif = (Time.new(t[0],t[1],t[2],0,0,0) - Time.new(f[0],f[1],f[2],0,0,0))/(60*60*24)
		        @val = Array.new
		        @queries = LogGlobalQuery.where("queries_date <= ? AND queries_date >= ?", @to, @from).where("#{query_statement}")
		       	@rr = LogGlobalQuery.where("queries_date <= ? AND queries_date >= ?", @to, @from).where("#{query_statement}")
		        @rr_type = LogGlobalQuery.select("resource").where("(queries_date <= ? AND queries_date >= ?)", @to, @from).where("#{query_statement}").group("resource").map{|x| [x.resource]}
		        logger.debug "!!! @rr_type #{@rr_type}"
		        get_rr = LogGlobalQuery.select("queries_date,resource,queries_count").where("queries_date >= ? AND queries_date <= ?", @from, @to).where("#{query_statement}").group_by(&:queries_date)
		        # @rr = LogZoneQuery.select("resource, queries_date, sum(queries_count) as queries_count2").where("(queries_date <= ? AND queries_date >= ?)", @to, @from).group("queries_date")
		        		        # @rr = LogZoneQuery.select("resource, queries_date, sum(queries_count) as queries_count2").where("(queries_date <= ? AND queries_date >= ?)", @to, @from).group("queries_date")
		        @total_queries = []
		        @date_group = []
				@rr_content2 = []

		        if @dif.floor < 7
		          @space = 1
		        elsif @dif.floor < 12
		          @space = 4
		        elsif @dif.floor < 60
		          @space = 7
		        else
		          @space = 30
		        end
		        (0..@dif.floor).each do |x|
		            v = (Time.new(f[0],f[1],f[2],0,0,0)+x.day).strftime("%Y-%m-%d")
		            @date_group.push(v)
		            total_queries = 0
		            rr_type_a_queries_count = 0
		            rr_type_aaaa_queries_count = 0

		            @queries.each do |q|
		              @a = v
		              @b = q.queries_date
		              if v.to_s == q.queries_date.to_s
		                total_queries = q.queries_count + total_queries
		              end
		            end

		            vv = v.split("-")
		            @rr_type.each do |rr|
						queries_count = 0

		            	# logger.debug "%%%get_rr[v.to_s] #{v.to_s} #{get_rr[v.to_date].nil?}"
			            unless get_rr[v.to_date].nil?
			            	tem = get_rr[v.to_date].group_by(&:resource)[rr[0]]
				            unless tem.nil?
				            	# logger.debug "$$$dddd #{v} #{rr} #{tem.map{|x| x.queries_count }.inject(:+)} "
				            	queries_count = tem.map{|x| x.queries_count }.inject(:+)
				            end
				        end

			            # @rr = LogZoneQuery.select("resource,queries_date,sum(queries_count) as queries_count2").where(:queries_date => v.to_s, :resource => rr)
		            	# temp = @rr.find_all{|x| x.resource == rr[0]}
		            	# logger.debug "###cari rr[0] #{rr[0]} @rr #{@rr.to_a}"


		            	# unless temp.empty?
		            	# 	temp.each do |tmp|
		            	# 		logger.debug "##tmp resource #{tmp.resource} "
		            	# 		if tmp.queries_date.to_s == v.to_s
		            	# 			queries_count = tmp.queries_count2
		            	# 		else
		            	# 			queries_count = 0
		            	# 		end
		            	# 	end
		            	# end


		            	@rr_content.push([rr[0],"[Date.UTC(#{vv[0]}, (#{vv[1].to_i-1}), #{vv[2]}), #{queries_count}],"])
		            	@rr_content2.push([v, rr[0], queries_count.to_i])
		            	@total_queries.push(queries_count)
		            end

		            @val.push("[Date.UTC(#{vv[0]}, (#{vv[1].to_i-1}), #{vv[2]}), #{total_queries}],")
		            
				# refactoring variable for table begin
					setup_query_variable
				# refactoring variable for table end		            

		        end

		        @total_queries = @total_queries.inject(:+)        

			end
	    end

# 	    respond_to do |format|
# 	    	format.js { render 'global_queries' }
# 	    	format.html {}
# 	    end
	end

	def global_country
		if params[:start_date].nil? or params[:date].nil?
	    	logger.debug "%%% 1"
	    else
	    	query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
	    	if params[:search_option] == "day"
		    	logger.debug "%%% 2"
				@countries = LogCountryCount.select("country_code, sum(queries_count) as query_sum").where("log_date = ? and queries_count != 0", "#{params[:date]}").where("#{query_statement}").group("country_code").order("query_sum desc")
				@countries_count = @countries.length
				@countries = @countries.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
				@countries_sum = LogCountryCount.select("country_code, sum(queries_count) as query_sum").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").sum("queries_count")
				
				# refactor begins
					setup_country_variable
				# refactor end
				
			elsif params[:search_option] == "range"
		    	logger.debug "%%% 3"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
				@countries = LogCountryCount.select("country_code, sum(queries_count) as query_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").group("country_code").order("query_sum desc")
				@countries_count = @countries.length
				@countries = @countries.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
				@countries_sum = LogCountryCount.select("country_code, sum(queries_count) as query_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").sum("queries_count")
				
				# refactor begins
					setup_country_variable
				# refactor end
			end
	    end
	end

	def global_ip
	    if params[:start_date].nil? or params[:date].nil?
	    else
	    	query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
	    	if params[:search_option] == "day"
				@ips = LogIp.select("log_country_id, ip, sum(hits_count) as hits_sum").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").group("ip").order("hits_sum desc")
				@ip_sum = LogIp.select("log_country_id, ip").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").sum(:hits_count)
				@ips_count = @ips.length
				@ips = @ips.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)

				# refactor begins
					setup_ip_variable
				# refactor end
				
			elsif params[:search_option] == "range"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
				@ips = LogIp.select("log_country_id, ip, sum(hits_count) as hits_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").group("ip").order("hits_sum desc")
				@ip_sum = LogIp.select("log_country_id, ip").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").sum(:hits_count)
				@ips_count = @ips.length
				@ips = @ips.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)

				# refactor begins
					setup_ip_variable
				# refactor end
			end
	    end
	end

	def global
		@zones = Zone.order("position")
	end

	def contoh
	 	# render :js => "alert('aaaa')"
	end

	def index
		get_zones
		@zone = Zone.first
		unless @zone.nil?
			# redirect_to zone_queries_graph_path(@zone)
			redirect_to hosts_graph_index_path
		end
	end

	def show
		render :index
	end


	def zone
	    get_zones_and_zone params[:id] 
	end

	def print_host
		# require 'open-uri'
		# open("http://#{request.host}:4000/reports/graph/via_my/print_zone?#{params.to_query}&auth_token=1h6TcmNtb6EvzdULKuAM")
		auth_token = "#{User.find_by_email("api@dnscell.com").authentication_token}"
		request_print_port = PRINT_PORT #use different server if child process is not supported
		if params[:search_option] == "day"
			file_name = "host_#{url2domain(params[:host_id])}_#{params[:date]}.pdf"
		elsif params[:search_option] == "range"
			d = params[:start_date].split(" ")
			file_name = "host_#{url2domain(params[:host_id])}_#{d[0]}_to_#{d[2]}.pdf"
		end
		PDFKit.new("http://#{request.host}:#{request_print_port}/reports/graph/print_host_process?#{params.to_query}&auth_token=#{auth_token}&print=yes", :orientation => "Portrait").to_file("#{Rails.root}/public/#{file_name}")
		send_file "#{Rails.root}/public/#{file_name}", :type=>"application/pdf", :x_sendfile=>true
	end

	def print_host_process #serving side
		host_queries
		host_countries
		host_ips
		render :layout => 'print'
	end

	def print_zone
		# require 'open-uri'
		# open("http://#{request.host}:4000/reports/graph/via_my/print_zone?#{params.to_query}&auth_token=1h6TcmNtb6EvzdULKuAM")
		auth_token = "#{User.find_by_email("api@dnscell.com").authentication_token}"
		request_print_port = PRINT_PORT #use different server if child process is not supported
		if params[:search_option] == "day"
			file_name = "zone_#{url2domain(params[:id])}_#{params[:date]}.pdf"
		elsif params[:search_option] == "range"
			d = params[:start_date].split(" ")
			file_name = "zone_#{url2domain(params[:id])}_#{d[0]}_to_#{d[2]}.pdf"
		end
		PDFKit.new("http://#{request.host}:#{request_print_port}/reports/graph/#{params[:id]}/print_query_country_ip?#{params.to_query}&auth_token=#{auth_token}&print=yes", :orientation => "Portrait").to_file("#{Rails.root}/public/#{file_name}")
		send_file "#{Rails.root}/public/#{file_name}", :type=>"application/pdf", :x_sendfile=>true
	end

	def print_query_country_ip #serving side
		zone_top_host
		zone_queries
		zone_country
		zone_ip
		render :layout => 'print'
	end

	def print_global
		# require 'open-uri'
		# open("http://#{request.host}:4000/reports/graph/via_my/print_zone?#{params.to_query}&auth_token=1h6TcmNtb6EvzdULKuAM")
		auth_token = "#{User.find_by_email("api@dnscell.com").authentication_token}"
		request_print_port = PRINT_PORT #use different server if child process is not supported
		if params[:search_option] == "day"
			file_name = "all_zone_#{params[:date]}.pdf"
		elsif params[:search_option] == "range"
			d = params[:start_date].split(" ")
			file_name = "all_zone_#{d[0]}_to_#{d[2]}.pdf"
		end
		PDFKit.new("http://#{request.host}:#{request_print_port}/reports/graph/print_query_country_ip_global?#{params.to_query}&auth_token=#{auth_token}&print=yes", :orientation => "Portrait").to_file("#{Rails.root}/public/#{file_name}")
		send_file "#{Rails.root}/public/#{file_name}", :type=>"application/pdf", :x_sendfile=>true
	end

	def print_query_country_ip_global #serving side
		 global_queries
		 global_country
		 global_ip
		top_zones
		if @table_content.nil?
			Option.find_by_statement("global_report_available").update_attributes(:statement_value => "false")
			render :text => "No data for this date."
		else
			Option.find_by_statement("global_report_available").update_attributes(:statement_value =>  "true")
			render :layout => 'print'
		end
	end

	def top_zones
		query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
		if params[:search_option] == "day"
			@top_zones = LogZoneQuery.select("zone_id,sum(queries_count) as result").where("queries_date >= ? and queries_date <= ?", params[:date], params[:date]).where("#{query_statement}").group("zone_id").order("result desc").limit(10).map{|x| [begin Zone.find(x.zone_id).zone_name rescue "unkown" end , x.result.to_int]}
			# @top_zones = Dnscell::Utils.top_zone params[:date], params[:date], 10
		elsif params[:search_option] == "range"
			d = params[:start_date].split(" ")
			@top_zones = LogZoneQuery.select("zone_id,sum(queries_count) as result").where("queries_date >= ? and queries_date <= ?", d[0], d[2]).where("#{query_statement}").group("zone_id").order("result desc").limit(10).map{|x| [begin Zone.find(x.zone_id).zone_name rescue "unkown" end , x.result.to_int]}
			# @top_zones = Dnscell::Utils.top_zone d[0], d[2], 10
		end
	end

	def zone_queries
	    get_zones_and_zone params[:id]
	    @date = Date.today.to_s
	    @x = []
		@rr_type_a = []
		@rr_type_aaaa = []
		@rr_content = []
		@rr_type = []
		@rr = []
		query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
		if params[:start_date].nil? or params[:date].nil?
	    	logger.debug "%%% 1"
	    	# @countries = @zone.log_country_counts.group("country_code")
	    else
	    	if params[:search_option] == "day"
		    	s = params[:date].split("-")
		    	@year = s[0]
		    	@month = s[1]
		    	@day = s[2]
				@queries = @zone.log_total_zone_queries.select("sum(log_1_count) as sumlog1, sum(log_2_count) as sumlog2, sum(log_3_count) as sumlog3, sum(log_4_count) as sumlog4, sum(log_5_count) as sumlog5, sum(log_6_count) as sumlog6, sum(log_7_count) as sumlog7, sum(log_8_count) as sumlog8, sum(log_9_count) as sumlog9, sum(log_10_count) as sumlog10, sum(log_11_count) as sumlog11, sum(log_12_count) as sumlog12, sum(log_13_count) as sumlog13, sum(log_14_count) as sumlog14, sum(log_15_count) as sumlog15, sum(log_16_count) as sumlog16, sum(log_17_count) as sumlog17, sum(log_18_count) as sumlog18, sum(log_19_count) as sumlog19, sum(log_20_count) as sumlog20, sum(log_21_count) as sumlog21, sum(log_22_count) as sumlog22, sum(log_23_count) as sumlog23, sum(log_24_count) as sumlog24").where("log_date = ?", "#{params[:date]}").first
				@query = @zone.log_total_zone_queries.select("
					resource,
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
					sum(log_24_count) as log_24_count
					").group(:resource).where("log_date = ?", "#{params[:date]}").where("#{query_statement}")
				@rr_content = []
				@rr_type = @query.map{|x| x.resource }

				# refactor begin
					setup_query_variable
				# refactor end

				@subtotal = []
				@query.each do |qry|
					sum = 0
					(0..23).each_with_index do |h,i|
						sum += eval("qry.log_#{i+1}_count")
					end
					# logger.debug "$$$$ sum #{sum}"
					@subtotal.push(sum)
				end

				# logger.debug "%%%rr_content #{@rr_content}"
		    	# logger.debug "%%%query #{@query.as_json} "	
			elsif params[:search_option] == "range"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
		        f = @from.split("-")
		        t = @to.split("-")
		        @dif = (Time.new(t[0],t[1],t[2],0,0,0) - Time.new(f[0],f[1],f[2],0,0,0))/(60*60*24)
		        @val = Array.new
		        @queries = LogZoneQuery.where("queries_date <= ? AND queries_date >= ?", @to, @from).where(:zone_id => @zone.id).where("#{query_statement}")
		        @rr_type = @zone.log_zone_queries.select("resource").where("(queries_date <= ? AND queries_date >= ?)", @to, @from).where("#{query_statement}").group("resource").map{|x| [x.resource]}
		        @rr = @zone.log_zone_queries.select("resource, queries_date, queries_count").where("(queries_date <= ? AND queries_date >= ?)", @to, @from).where("#{query_statement}")
		        @total_queries = []
		        @date_group = []
				@rr_content2 = []

		        if @dif.floor < 7
		          @space = 1
		        elsif @dif.floor < 12
		          @space = 4
		        elsif @dif.floor < 60
		          @space = 7
		        else
		          @space = 30
		        end

		        (0..@dif.floor).each do |x|
		            v = (Time.new(f[0],f[1],f[2],0,0,0)+x.day).strftime("%Y-%m-%d")
		            @date_group.push(v)
		            total_queries = 0
		            rr_type_a_queries_count = 0
		            rr_type_aaaa_queries_count = 0

		            @queries.each do |q|
		              @a = v
		              @b = q.queries_date
		              if v.to_s == q.queries_date.to_s
		                total_queries = q.queries_count + total_queries
		              end
		            end

		            vv = v.split("-")
					# subtotal = 0
		            @rr_type.each do |rr|
						queries_count = 0
		            	temp = @rr.find_all{|x| x.resource == rr[0]}
		            	unless temp.empty?
		            		temp.each do |tmp|
		            			if tmp.queries_date.to_s == v.to_s
		            				queries_count = tmp.queries_count
		            			end
		            		end
		            	end
		            	@rr_content.push([rr[0],"[Date.UTC(#{vv[0]}, (#{vv[1].to_i-1}), #{vv[2]}), #{queries_count}],"])
		            	@rr_content2.push([v, rr[0], queries_count])
		            	@total_queries.push(queries_count)
    				# subtotal += queries_count
		            end

		            @val.push("[Date.UTC(#{vv[0]}, (#{vv[1].to_i-1}), #{vv[2]}), #{total_queries}],")
		        end

				# refactoring variable for table begin
					setup_query_variable
				# refactoring variable for table end

		        @total_queries = @total_queries.inject(:+)
		        logger.debug "$$$$table_content #{@table_content}"
			end
	    end

	    # respond_to do |format|
	    # 	format.js { render 'zone_queries' }
	    # 	format.html {}
	    # end
	end

	def zone_country
	    get_zones_and_zone params[:id]
		if params[:start_date].nil? or params[:date].nil?
	    	logger.debug "%%% 1"
	    	# @countries = @zone.log_country_counts.group("country_code").collect{|c| [c.country_code, LogCountryCount.sum("queries_count", :conditions=>"country_code='#{c.country_code}'").to_i] }.sort {|x,y| y[1] <=> x[1] }

			@countries = @zone.log_country_counts.select("country_code, sum(queries_count) as query_sum").group("country_code").order("query_sum desc")
	    	# @countries = @zone.log_country_counts.find(:all,
      #                         :select => "SUM(queries_count) as queries_sum",
      #                         :group => "country_code")
			@countries_count = @countries.length
			@countries = @countries.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
			@countries_sum = @zone.log_country_counts.sum("queries_count")
	    	# @countries = @zone.log_country_counts.group("country_code")
	    else
			query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
	    	if params[:search_option] == "day"
		    	logger.debug "%%% 2"
				@countries = @zone.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").group("country_code").order("query_sum desc")
				@countries_count = @countries.length
				@countries = @countries.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
				@countries_sum = @zone.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").sum("queries_count")
				logger.debug "%%%%countries #{@countries.to_a}"

				# refactor begins
					setup_country_variable
				# refactor end

			elsif params[:search_option] == "range"
		    	logger.debug "%%% 3"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
				query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
				@countries = @zone.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").group("country_code").order("query_sum desc")
				@countries_count = @countries.length
				@countries = @countries.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
				@countries_sum = @zone.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").sum("queries_count")

				# refactor begins
					setup_country_variable
				# refactor end
			end
	    end

# 	    respond_to do |format|
# 	    	format.js { render 'zone_country' }
# 	    	format.html {}
# 	    end
	end

	def ip
		get_zones
	end

	def zone_ip
	    get_zones_and_zone params[:id]
	    if params[:start_date].nil? or params[:date].nil?
	    	# @countries = @zone.log_country_counts.group("country_code").collect{|c| [c.country_code, LogCountryCount.sum("queries_count", :conditions=>"country_code='#{c.country_code}'").to_i] }.sort {|x,y| y[1] <=> x[1] }
			@ips = @zone.log_ips.select("log_country_id, ip, sum(hits_count) as hits_sum").group("ip").order("hits_sum desc")
	    	# @countries = @zone.log_country_counts.find(:all,
      #                         :select => "SUM(queries_count) as queries_sum",
      #                         :group => "country_code")
			@ips_count = @ips.length
			@ips = @ips.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
	    	# @countries = @zone.log_country_counts.group("country_code")
	    	logger.debug "%%% 1"
	    else
			query_statement = params[:node] == "all" ? "" : "node_id = #{params[:node]}"
	    	if params[:search_option] == "day"
				@ips = @zone.log_ips.select("log_country_id, ip, sum(hits_count) as hits_sum").where("log_date = ?", "#{params[:date]}").where("#{query_statement}").group("ip").order("hits_sum desc")
				#@ip_sum = @zone.log_ips.select("log_country_id, ip, sum(hits_count) as hits_sum").where("log_date = ?", "#{params[:date]}").first.hits_sum.to_i
				@ip_sum = @zone.log_ips.select("log_country_id, ip").where("log_date = ?", "#{params[:date]}").sum(:hits_count)
				@ips_count = @ips.length
				@ips = @ips.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
		    	logger.debug "%%% #{@ip_sum}"

				# refactor begins
					setup_ip_variable
				# refactor end
			elsif params[:search_option] == "range"
		        s = params[:start_date].split("-")
		        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
		        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
				@ips = @zone.log_ips.select("log_country_id, ip, sum(hits_count) as hits_sum").where("log_date <= ? AND log_date >= ?", @to, @from).where("#{query_statement}").group("ip").order("hits_sum desc")
				@ip_sum = @zone.log_ips.select("log_country_id, ip)").where("log_date <= ? AND log_date >= ?", @to, @from).sum(:hits_count)
				@ips_count = @ips.length
				@ips = @ips.paginate(:page => params[:page].nil? ? 1 : params[:page] ,:per_page => 10)
		    	logger.debug "%%% #{@ip_sum}"
		    	
				# refactor begins
					setup_ip_variable
				# refactor end
				
			end
	    end
	end

	def country
		get_zones
	end

	def get_zones
		@zones = Zone.all
	end

	def setup_query_variable
		if params[:search_option] == "day"
			unless @rr_type.empty?
				@table_content = []
				@table_content[0] = ["Hour"] + @rr_type + ["Queries"] + ["Percentage"]
				#getting rr item sum
					rr_sum = []
					@rr_type.each_with_index do |get_rr_total,i|
						rr_item_count = 0
						(0..23).each do |h|
							rr_item_count += @query.map{|x| eval("x.log_#{h+1}_count") }[i]
						end
						rr_sum += [rr_item_count]
					end
					rr_sum = ["Total"] + rr_sum
				#getting rr item sum end

				#getting total of query for percentage purpose
				tambah_temp = 0
				(1..24).each do |tambah|
					temp = @query.map{|x| eval("x.log_#{tambah}_count") }
					unless temp.nil?
						tambah_temp += temp.inject(:+)
					else
						tambah_temp += 0
					end
				end
				#getting total of query for percentage purpose - END

				#construct the major table data
				(0..23).each_with_index do |hour,hi|
						@rr_content[hi] = @query.map{|x| eval("x.log_#{hi+1}_count") }
						@table_content[hi+1] = ["#{'%02d' % hour}:00 - #{'%02d' % (hour.to_i+1)}:00"]
						temp = @query.map{|x| eval("x.log_#{hi+1}_count") }
						@table_content[hi+1] = @table_content[hi+1] + temp
						@table_content[hi+1].push(temp.inject(:+))
						@table_content[hi+1].push((@table_content[hi+1].last.to_f / tambah_temp.to_f * 100).round(2))
				end

					#sum the percentage & rr subtotal
						hundred_percent = 0
						(1..24).each do |e|
							hundred_percent += @table_content[e].last
						end
					#sum the percentage end
				@table_content.push(rr_sum + [tambah_temp] + [hundred_percent.round])
				#construct the major data end
			end
		elsif params[:search_option] == "range"
			unless @queries.blank?
				@table_content = []

				#need to get whole of queries_count for the percentage
				whole_queries_count = 0
				@rr.group_by{|x| x.queries_date.to_s}.keys.each_with_index do |dg,i|
					whole_queries_count += @rr.select{|x| x.queries_date.to_s == dg}.map{|x| x.queries_count }.inject(:+)
				end
				#need to get whole of queries_count for the percentage end

				whole_percent = 0
     			@table_content[0] = ["Date"] + @rr.group_by(&:resource).keys + ["Queries"] + ["Percentage (%)"]

     			date = []
     			(0..@dif.to_i).each do |date_diff|
     				date += [(@from.to_date + date_diff).to_s]
	     		end

	     		# logger.debug "###date #{date}"

	         	date.each_with_index do |dg,i|
	         		count_rr = @rr.select{|x| x.queries_date.to_s == dg}.map{|x| x.queries_count }.inject(:+)
	         		@table_content[i+1] = [dg]
	         		@rr.group_by(&:resource).keys.each do |rr_type|
	         			temp_data = @rr.select{|x| x.queries_date.to_s == dg }.find{|x| x.resource == rr_type}
	         			temp_data = temp_data.nil? ? 0 : temp_data.queries_count
		         		@table_content[i+1] += [temp_data] 
	         		end

	         		rr_percent = (count_rr.to_f/whole_queries_count.to_f*100).round(2)
	         		@table_content[i+1] += [count_rr.nil? ? 0 : count_rr] + [rr_percent]# + percentange
	         		whole_percent += rr_percent
	         		# logger.debug "$$$$count_rr #{count_rr}"
	         	end

	         	# formatting the last row
	         		last_row = ["Total"]
					@rr.group_by(&:resource).keys.each do |rr_type|
						last_row += [@rr.select{|x| x.resource == rr_type}.map{|x| x.queries_count }.inject(:+)]
					end
					last_row += [whole_queries_count] + [whole_percent.round]
					@table_content.push(last_row)
				# formatting the last row end
			end
		end
	end

	def setup_ip_variable
		unless @ips.blank?
			@ip_table = [["IP", "Queries", "Percentage (%)"]]
			# c.log_country.country_code2.downcase
			top10_sum = @ips.map{|x| x.hits_sum }.inject(:+)
			@ip_table += @ips.map{|x| [x.log_country.country_code2.downcase + " " + x.ip , x.hits_sum.to_i, (x.hits_sum.to_f/top10_sum.to_f*100).round(2)]}
			# sum_temp = @ips.map{|x| x.hits_sum}.inject(:+)
			# @ip_table += [["Other(s)", sum_temp.to_i , ((@ip_sum - sum_temp.to_f)/@ip_sum.to_f*100).round(2) ]]
			# logger.debug "%%%%ip_table #{@ip_table}"
		end
	end

	def setup_country_variable
		unless @countries.blank?
			@country_table = [["Country", "Queries", "Percentage (%)"]]
			top10_sum = @countries.map{|x| x.query_sum }.inject(:+)
			@country_table += @countries.map{|x| [x.country_code, x.query_sum.to_i, (x.query_sum.to_f/top10_sum.to_f*100).round(2)]}
			# sum_temp = @countries.map{|x| x.query_sum}.inject(:+)
			# @country_table += [["Other(s)", sum_temp.to_i , ((@countries_sum - sum_temp.to_f)/@countries_sum.to_f*100).round(2) ]]
			# logger.debug "%%%%country_table #{@country_table}"
		end
	end

	def zone_top_host
		if params[:search_option] == "day"
			date = params[:date]
			@top_host_table_content = Dnscell::Utils.get_top_host_for_zone_base_on_date Zone.find_by_zone_name(url2domain(params[:id])).id, date, 10 if date
			prepare_top_host_variable
			logger.debug "##### zone_top_host "
		elsif params[:search_option] == "range"
			@from = params[:start_date].split(" ")[0]
			@to = params[:start_date].split(" ")[2]
			@top_host_table_content = Dnscell::Utils.zone_top_host Zone.find_by_zone_name(url2domain(params[:id])).id, @from, @to, 10
			prepare_top_host_variable
		end
	end

	def prepare_top_host_variable
			total = @top_host_table_content.map{|x| x[1] }.inject(:+)
			@top_host_table_content = @top_host_table_content.map{|x| [x[0], x[1], (x[1].to_f/total*100).round(2) ]}
			unless @top_host_table_content.blank?
				temp = [["Host", "Queries", "Percentage (%)"]]
				@top_host_table_content.each{|x| temp.push(x) }
				@top_host_table_content = temp
			end
			logger.debug "$$$top_host_table_content #{@top_host_table_content}"
	end
end
