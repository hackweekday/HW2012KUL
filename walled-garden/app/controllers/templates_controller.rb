class TemplatesController < ApplicationController
	set_tab :zone_management
	set_tab :templates, :first_level
	set_tab :soa, :second_level, :only => %w(soa)
	set_tab :ns, :second_level, :only => %w(ns)
	set_tab :host, :second_level, :only => %w(hosts)

	def paginated_hosts
		@template = Template.find(params[:id])
		logger.debug "%%%%% #{@template.id}"
	case params[:iSortCol_0]
	when "0"
		sort_variable = "created_at desc"
	when "1"
		sort_variable = "combine #{params[:sSortDir_0]}"
	when "2"
		sort_variable = "created_at #{params[:sSortDir_0]}"
	end
		@hosts = @template.template_hosts.order("created_at desc")
		@hosts_count = @hosts.count
		@from = "admin"
	end

	def sort
		params[:sidebar_list].each_with_index do |p,i|
			Template.find(p).update_attributes(:position => i+1)
		end
		#render :js => "show_flash('Position saved.')"
		render :text => ""
	end

	def hosts
		all_template
		@template = Template.find(params[:id])
	end

	def index
		@templates = Template.order("position")
		@template = Template.last
		if @template 
			redirect_to hosts_template_path(@template)
		end

	end

	def new
		@template = Template.new
	end

	def create
		@template = Template.new(params[:template])
		if @template.save
			# Create Initial host
       		h = @template.template_hosts.build(:read_only => true, :typ => 0, :domain => "zonename", :subdomain => "@", :reference => "zonename", :combine => "zonename", :status => 1, :read_only => true, :share => true)
       		h.save
       		# Create Initial SOA 
       		s = TemplateSoa.create(
       			:sn => 1,
       			:template_id => @template.id
       		)
       		# Create SOA records
       		s_record = h.template_records.build(
       			 :rr_type => "SOA",
       			 :data => "<same as SOA template>", :read_only => true,
       			 :rr_host => "@", :rr_zone => "zonename" 
       		)
       		s_record.save(:validate => false)

			flash[:notice] = "Template created."
			#amir 9/2/2012 - add $('#template_form').dialog('close')
			render :js => "$('#template_form').dialog('close');window.location = '#{templates_path}'"
		else
			@error = @template.errors.full_messages
			render 'error.js'
		end
	end

	def delete
		t = Template.find(params[:id])

		t.destroy
		redirect_to :action => :index
	end

	def show
		all_template
		@template = Template.find(params[:id])
		render 'index'
	end

	def soa
		all_template
		@template = Template.find(params[:id])
		@soa = @template.template_soa
		@soa = TemplateSoa.new if @soa.nil?
	end

	def create_soa
		@soa = TemplateSoa.new(params[:template_soa])
		@soa.template_id = params[:id]
		if @soa.save
			flash[:notice] = "SOA saved."
			render :js => "window.location = '#{soa_template_path(params[:id])}'"
		else
			@error = @soa.errors.full_messages
			render 'error.js'
		end
	end

	def update_soa
		@soa = TemplateSoa.find(params[:template_soa][:id])
		if @soa.update_attributes(params[:template_soa])
			flash[:notice] = "SOA saved."
			render :js => "window.location = '#{soa_template_path(params[:id])}'"
		else
			@error = @soa.errors.full_messages
			render 'error.js'
		end
	end

	def ns
		all_template
		@primary = TemplateNameServer.where(:template_id => params[:id], :primary => 1)
		logger.debug "#### #{@primary.to_a}"
		@secondary = TemplateNameServer.where(:template_id => params[:id], :primary => 0)

		@template = Template.find(params[:id])
	end

	def new_ns
		@ns = TemplateNameServer.new
		unless params[:t] == "primary"
			@ns.ns_ttl = TemplateNameServer.where(:template_id => params[:id], :primary => true).first.ns_ttl
			@ns.primary = false
		else
			@ns.primary = true
		end
	end

	def create_ns
		@ns = TemplateNameServer.new(params[:template_name_server])
		# @ns.glue = params[:template_name_server][:glue_or_not].gsub(/glue|non-glue/, 'non-glue' => 0, 'glue' => 1)
		@ns.primary = params[:t].gsub(/primary|secondary/, 'primary' => true, 'secondary' => false)
		@ns.template_id = params[:id]
		if @ns.save
			flash[:notice] = "Name Server saved."
			render :js => "$('#ns_form').dialog('close');window.location = '#{ns_template_path(params[:id])}'"
		else
			@error = @ns.errors.full_messages
			render 'error.js'
		end
	end

	def delete_ns
		ns = TemplateNameServer.find(params[:ns_id])
		ns.normal_destroy = true
		ns.destroy
		redirect_to ns_template_path(params[:id]), :notice => "Name Server deleted."
	end

	def edit_ns
		@ns = TemplateNameServer.find(params[:ns_id])
		# @ns.glue_or_not = @ns.glue? ? "glue" : "non-glue"
		h = TemplateHost.where(:subdomain => "@", :template_id => params[:id]).first
		if @ns.glue
			rr_host = @ns.ns.gsub(".zonename", "")
			@ns.host_id = TemplateHost.where(:combine => @ns.ns, :template_id => params[:id]).first.id
			#get the glue records A, AAAA & NS find the data or what?
			record_id_a = TemplateRecord.where(:rr_type => "A", :rr_host => rr_host, :template_host_id => @ns.host_id ).first
			record_id_aaaa = TemplateRecord.where(:rr_type => "AAAA", :rr_host => rr_host, :template_host_id => @ns.host_id ).first

			unless record_id_a.blank?
				@ns.record_id_a = record_id_a.id
			end

			unless record_id_aaaa.blank?
				@ns.record_id_aaaa = record_id_aaaa.id

			end
		end

		@ns.record_id_ns = TemplateRecord.where(:data => @ns.ns, :template_host_id => h.id ).first.id
		@ns.ns = @ns.ns.gsub(".zonename", "")
		@ns.current_host = @ns.ns
		render 'new_ns.js'
	end

	def save_ns
		@ns = TemplateNameServer.find(params[:ns_id])
		logger.debug "%%%%% #{@ns.ns}"
		# @ns.glue = params[:template_name_server][:glue_or_not].gsub(/glue|non-glue/, 'non-glue' => 0, 'glue' => 1)
		if @ns.update_attributes(params[:template_name_server])
			slaves = TemplateNameServer.where(:template_id => params[:id], :primary => false).update_all(:ns_ttl => @ns.ns_ttl)
			flash[:notice] = "Name Server saved."
			render :js => "$('#ns_form').dialog('close');window.location = '#{ns_template_path(params[:id])}'", :notice => "Name Server saved."
		else
			@error = @ns.errors.full_messages
			render 'error.js'
		end
	end

	def all_template 
		@templates = Template.where(:name => 'Default') + Template.order("position").order("created_at desc").where("name not in ('Default')")
	end
end
