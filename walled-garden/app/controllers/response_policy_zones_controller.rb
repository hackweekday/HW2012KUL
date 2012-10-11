class ResponsePolicyZonesController < ApplicationController
	set_tab :dnsrpz, :first_level, :only => %w(index new show category)
	set_tab :rpz_cat, :rpz_tab, :only => %w(category)
	set_tab :response_policy, :rpz_tab, :only => %w(index show)

	def opt_edit
	end

	def options
		@options = Option.all
		@at = get_option("dnsrpz_allow-transfer")
		case @at
		when "1"
		when "2"
		when "3"
		end
	end

	def category
		@options = Option.all
		@categories = DnsrpzCategory.all
		@category = DnsrpzCategory.new
		@provider = Dnsrpz.first
	end

	def delete_category
		c = DnsrpzCategory.find(params[:id])
		c.destroy
		@notice = "Category deleted!"
		@categories = DnsrpzCategory.all
	end

	def create_category
		@category = DnsrpzCategory.new(params[:dnsrpz_category])
		case @category.category_type
		when "Time Range"
			@category.dnsrpz_time = DnsrpzTime.new
			@category.dnsrpz_time.start = params[:start]
			@category.dnsrpz_time.end = params[:end]
		end
		if @category.save
			@notice = "Category deleted!"
			@categories = DnsrpzCategory.all
		else
			@error = @category.errors.full_messages
			render 'error.js'
		end
	end

	def update_record
		@record = DnsrpzRecord.find(params[:dnsrpz_record][:record_id])
		case params[:dnsrpz_record][:rr_type]
		when "NX Domain" 
			@record.rr_type = "CNAME"
			@record.data = "."
		when "NO Error"
			@record.rr_type = "CNAME"
			@record.data = "*."
		else
			@record.rr_type = params[:dnsrpz_record][:rr_type]
			@record.data = params[:dnsrpz_record][:data]
		end
		@record.rr_host = "#{params[:dnsrpz_record][:rr_host]}"
		@record.dnsrpz_category_id = "#{params[:dnsrpz_record][:dnsrpz_category_id]}"
		if @record.save
			@notice = "Record updated"
			@records = DnsrpzRecord.all
			render 'create_record.js'
		else
			@error = @record.errors.full_messages
			render 'error.js'
		end
	end

	def edit_record
		@record = DnsrpzRecord.find(params[:id])
		@form_path = update_record_response_policy_zones_path
		render 'new_record.js'
	end

	def delete_record
		r = DnsrpzRecord.find(params[:id])
		r.destroy
		@notice = "Policy deleted"
		@records = DnsrpzRecord.all
		render 'create_record.js'
	end

	def create_record
		@record = DnsrpzRecord.new(params[:dnsrpz_record])
		case @record.rr_type
		when "NX Domain"
			@record.rr_type = "CNAME"
			@record.data = '.'
		when "NO Error"
			@record.rr_type = "CNAME"
			@record.data = '*.'
		end
		if @record.save
			@notice = "Policy created!"
			@records = DnsrpzRecord.all
		else
			@error = @record.errors.full_messages
			render 'error.js'
		end
	end

	def new_record
		@record = DnsrpzRecord.new
		@form_path = create_record_response_policy_zones_path
	end

	def destroy
		@option = Dnsrpz.find(params[:id])
		@option.destroy
		redirect_to :action => :index
	end

	def index
		@options = Option.all
		@providers = Dnsrpz.all
		@provider = Dnsrpz.first
		@records = DnsrpzRecord.all
		redirect_to response_policy_zone_path(@provider)
	end

	def show
		@options = Option.all
		@providers = Dnsrpz.all
		@provider = Dnsrpz.find(params[:id])
		@records = DnsrpzRecord.all
		#render :text => "#{@provider.provider_name}"
	end

	def new
		case params[:step]
		when "1"
			# @option
			@provider = Dnsrpz.new(:zone => Zone.new)
		when "2"
			@masters = Master.all
			@master = Master.new
		else
		end
	end
	def create
		case params[:step]
		when '1'
			@provider = Dnsrpz.new(params[:dnsrpz])
			# @provider.zones.zone_name = params[:zone][:zone_name]
			if @provider.save
				render :js => "window.location = '#{new_response_policy_zone_path}?step=2&id=#{@provider.zone.id}'"
			else
				@error = @provider.errors.full_messages
				# render :js => "alert('#{@provider.errors.full_messages}')"
				render 'error.js'
			end
		when '2'

		end
	end
end

