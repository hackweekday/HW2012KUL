class TemplateHostsController < ApplicationController
	layout nil

	def show
	end

	def new
		@host = TemplateHost.new(:template_id => params[:template_id])
		render 'new.js'
	end

	def create
		@host = TemplateHost.new(params[:template_host])
		@host.typ = 1
		@host.status = 1
		@host.reference2 = @host.subdomain
		@host.domain = "zonename"
		@host.reference = "zonename"
		@host.read_only = false
		@host.combine = "#{params[:template_host][:subdomain]}.zonename"
		if @host.save
			render :js => "
				$('.ui-dialog-content').dialog('close');
				show_flash('Host saved.');
				$('#dttb_host').dataTable().fnDraw(false)
				$('#action').val('#{params[:action]}')
				"
		else
			@error = @host.errors.full_messages
			render 'error.js'
		end
	end

	def delete_hosts
		params[:host_ids].each do |h|
			TemplateHost.find(h).destroy
		end
		render :js => "$('#dttb_host').dataTable().fnDraw(false);show_flash('Host deleted.')"
	end

	def format_data
		if params[:resource] == "Others"
			pre_rr_type = params[:record_others].nil? ? params[:template_record][:rr_type] : params[:record_others][:rr_type]
			@rr_type = pre_rr_type
		else
			@rr_type =  params[:resource]
		end
		case params[:resource]
		when "MX"
			@data = "#{@record.mx_priority} #{@record.data}"
		else
			@data = @record.data
		end
	end

	def rr_save
		unless params[:record_id].nil?
			@record = eval("Record#{params[:resource].capitalize}.new(params[:template_record])")
			if @record.valid?
				r = TemplateRecord.find(params[:record_id])
				format_data
				if r.update_attributes(:template_host_id => params[:id], :rr_type => @rr_type, :data => "#{@data}", :ttl => @record.ttl)
					render :js => "
						$('.ui-dialog-content').dialog('destroy')
						show_flash('Record updated.');
						$('#dttb_host').dataTable().fnDraw(false);
						$('#action').val('#{params[:action]}')
						$('#host_id').val('#{params[:id]}')
						"	
				else
						@error = r.errors.full_messages
						render 'error.js'
				end
			else
				@error = @record.errors.full_messages
				render 'error.js'
			end
		else
			template = TemplateHost.find(params[:id])
			@record = eval("Record#{params[:resource].capitalize}.new(params[:record_#{params[:resource].downcase}])")
			if @record.valid?
				format_data

				t = TemplateRecord.new(:rr_host => template.subdomain, :rr_zone => template.domain, 
				:template_host_id => params[:id], :rr_type => @rr_type, :data => "#{@data}", 
				:ttl => @record.ttl)
				if t.save
					render :js => "
						$('.ui-dialog-content').dialog('destroy')
						show_flash('Record saved.');
						$('#dttb_host').dataTable().fnDraw(false);
						$('#action').val('#{params[:action]}')
						$('#host_id').val('#{params[:id]}')
						"
				else
					@error = t.errors.full_messages
					render 'error.js'				
				end
			else
				@error = @record.errors.full_messages
				render 'error.js'
			end
		end
	end

	def rr_delete
		TemplateRecord.find(params[:record_id]).destroy
		render :js => "
			show_flash('Record deleted.');
			$('#dttb_host').dataTable().fnDraw(false);
			$('#action').val('#{params[:action]}')
			$('#host_id').val('#{params[:id]}')
			"
	end

	def rr_edit
		@record = TemplateRecord.find(params[:record_id])
		@host = TemplateHost.find(params[:id])
      case params[:rr_type]
      when "TXT"
        @record.data = @record.data.gsub('"', '')
      when "MX"
        temp_arr = @record.data.split(" ")
        length = temp_arr.length
        @record.data = temp_arr[length-1]
        @record.mx_priority = temp_arr[0]
      when "SRV"
        temp_arr = @record.data.split(" ")
        length = temp_arr.length
        # @data.priority = temp_arr[0]
        # @data.weight = temp_arr[1]
        # @data.port = temp_arr[2]
        # @data.target = temp_arr[3]
      end
		available_rr_type = ["A", "MX", "AAAA", "TXT", "CNAME", "NS", "PTR", "SRV"]
		if available_rr_type.find_all{|x| x == params[:rr_type]}.length > 0
			render "templates/records/#{params[:rr_type].downcase}"
		else
			render "templates/records/others"
		end
		# render "templates/records/#{params[:rr_type].downcase}.js"
	end

	def rr_new
		@template = Template.find(params[:template_id])
		@host = TemplateHost.find(params[:id])
	    if params[:add].blank?
	        if current_user.role?
	          redirect_to domains_path
	        end
	    else
	        case params[:add]
	        when "A"
	          @record = RecordA.new
	          @record.rr_type = "A"
	          render 'templates/records/a.js'
	        when "AAAA"
	          @record = RecordAaaa.new
	          @record.rr_type = "AAAA"
	          render 'templates/records/aaaa.js'
	        when "TXT"
	          @record = RecordTxt.new
	          @record.rr_type = "TXT"
	          render 'templates/records/txt.js'
	        when "CNAME"
	          @record = RecordCname.new
	          @record.rr_type = "CNAME"
	          render 'templates/records/cname.js'
	        when "MX"
	          @record = RecordMx.new
	          @record.rr_type = "MX"
	          render 'templates/records/mx.js'
	        when "NS"
	          @record = RecordNs.new
	          @record.rr_type = "NS"
	          render 'templates/records/ns.js'
	        when "PTR"
	          @record = RecordPtr.new
	          @record.rr_type = "PTR"
	          render 'templates/records/ptr.js'
	        when "SRV"
	          @record = RecordSrv.new
	          @record.rr_type = "SRV"
	          render 'templates/records/srv.js'
	        when "Others"
	          @record = RecordOthers.new
	          @record.rr_type = ""
	          render 'templates/records/others.js'
	        else 
	          render 'hosts/rr/resource_records'
	        end
	    end
	end

end
