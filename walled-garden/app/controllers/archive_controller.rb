class ArchiveController < ApplicationController
	def index
		@files = `ls public/archive`.split("\n")
		unless @files.empty?
			if (o "current_archive").blank?
				Option.find_by_statement("current_archive").update_attributes(:statement_value => @files[0])
			end
		end
	end

	def display
		# CURRENT_ARCHIVE = params[:id]
		Option.find_by_statement("current_archive").update_attributes(:statement_value => params[:id])
		render :nothing => true
	end

	def zone_query
		@log_zone_queries = ArchiveLogZoneQuery.order(:queries_date).paginate(:page => (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i)+1 ,:per_page => params[:iDisplayLength])
		@log_zone_queries_count = @log_zone_queries.count
	end

	def total_zone_query
		@total_log_zone_queries = ArchiveTotalLogZoneQuery.paginate(:page => (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i)+1 ,:per_page => params[:iDisplayLength])
		@total_log_zone_queries_count = @total_log_zone_queries.count
	end

	def country_count
		@log_country_counts = ArchiveLogCountryCount.paginate(:page => (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i)+1 ,:per_page => params[:iDisplayLength])
		@log_country_counts_count = @log_country_counts.count
	end

	def ip
		@log_ips = ArchiveLogIp.paginate(:page => (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i)+1 ,:per_page => params[:iDisplayLength])
		@log_ips_count = @log_ips.count
	end

	def host_query
		@log_host_queries = ArchiveLogHostQuery.order(:queries_date).paginate(:page => (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i)+1 ,:per_page => params[:iDisplayLength])
		@log_host_queries_count = @log_host_queries.count
	end

	def total_host_query
		@total_log_host_queries = ArchiveLogTotalHostQuery.paginate(:page => (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i)+1 ,:per_page => params[:iDisplayLength])
		@total_log_host_queries_count = @total_log_host_queries.count
	end

	def global_query
		@log_global_queries = ArchiveLogGlobalQuery.order(:queries_date).paginate(:page => (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i)+1 ,:per_page => params[:iDisplayLength])
		@log_global_queries_count = @log_global_queries.count
	end

	def total_global_query
		@total_log_global_queries = ArchiveLogTotalGlobalQuery.order(:log_date).paginate(:page => (params[:iDisplayStart].to_i / params[:iDisplayLength].to_i)+1 ,:per_page => params[:iDisplayLength])
		@total_log_global_queries_count = @total_log_global_queries.count
	end

	def download
		send_file "#{ARCHIVE_DIR}/#{Option.find_by_statement('current_archive').statement_value}", :type=>"application/sqlite", :x_sendfile=>true
	end

	def save
		Option.find_by_statement("month_count_to_archive").update_attributes(:statement_value => params[:month_count_to_archive])
		render :js => "show_flash('Saved.');$('.archive_form').hide()"
	end
end
