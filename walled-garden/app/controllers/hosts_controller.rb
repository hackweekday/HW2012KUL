class HostsController < ApplicationController
  set_tab :zone_management
  set_tab :zones, :first_level
  set_tab :host, :second_level
  set_tab :resource_records, :host_level, :only => %w(resource_records rr_create)
  set_tab :logs, :host_level, :only => %w(logs)
  set_tab :host_dashboard, :third_level, :only => %w(show)
  #set_tab :zones,  :navigation, :only => %w(index)
  skip_filter :only_admin, :only => %w(new create resource_records rr_create rr_remove delete_hosts unnotify_request_check unnotify_msg_check notifying_records_request unnotify_request_check notifying_msg render_msg render_request)
  
  def get_paginated_compact_slave_hosts
      @zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
      sort_variable = ""
      @hosts = @zone.hosts.where("combine like ?", "%#{params[:sSearch]}%").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      # @hosts = @records.group(:rr_host).map{|x| [x.id, x.rr_host, x.created_at] }
      # .where("version = '#{@zone.soa_serial.serial_number}' and (rr_host like ? or content like ?)", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%").
      @records_count = @hosts.count
  end

  def get_paginated_slave_hosts
    @zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
    case params[:iSortCol_0]
    when "0"
      sort_variable = "created_at desc"
    when "1"
      sort_variable = "node_name #{params[:sSortDir_0]}"
    when "2"
      sort_variable = "created_at #{params[:sSortDir_0]}"
    end
      @records = @zone.slave_records.where("version = '#{@zone.soa_serial.serial_number}' and (rr_host like ? or content like ?)", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      @records_count = @records.count
      # @nodes = @zone.nodes.where("node_name LIKE ? AND node_type = '#{node_type}'", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      # @unassigned_nodes = @zone.zone_nodes.empty? ? Node.where("status = 1 AND node_type = 'secondary'") : Node.where("status = 1 AND node_type = 'secondary' AND id not in (?)", @zone.zone_nodes.map{|zn| zn.node_id })
      # logger.debug "** #{@zone.zone_nodes.map{|zn| zn.node_id}}"
  end


  def process_multiple_record_request

    case params[:process_type]
    when "approve"
      params[:request_ids].split(",").each do |request|
        request = RecordsRequest.find(request)
        record = Record.find(request.record_id)
        host = record.host
        Resque.enqueue(CreateRecordApplication, record.id, request.user_id)
        request.update_attributes(:approved_status => 1)
        record.update_attributes(:delete_state => 0)
        write_msg current_user.id, request.user_id, "Your request [Add #{record.rr_type} #{record.data} INTO #{host.combine}] has been Approved", 1
      end
    when "reject"
      params[:request_ids].split(",").each do |request|
        request = RecordsRequest.find(request)
        record = Record.find(request.record_id)
        host = record.host
        request.update_attributes(:approved_status => 2)
        record.update_attributes(:delete_state => 1)
        write_msg current_user.id, request.user_id, "Your request [Add #{record.rr_type} #{record.data} INTO #{host.combine}] has been Rejected", 2
      end
    end
    render :js => "$('#records_request_dttb').dataTable().fnDraw(false)"
  end

  def process_request
    request = RecordsRequest.find(params[:request_id])
    record = Record.find(request.record_id)
    host = record.host
    if params[:state] == "1"
      Resque.enqueue(CreateRecordApplication, record.id, request.user_id)
      request.update_attributes(:approved_status => 1)
      request_state = "Approved"
      record.update_attributes(:delete_state => false, :active => true)
    else
      request.update_attributes(:approved_status => 2)
      request_state = "Rejected"
      if record.update_attributes(:delete_state => true)
        logger.debug "** rejec"
      end
    end
      Record.find(request.record_id).update_attributes(:approval_state => false)
      write_msg current_user.id, request.user_id, "Your request [Add #{record.rr_type} #{record.data} INTO #{host.combine}] has been #{request_state}.", params[:state]
      render :js => "$('#request_#{params[:request_id]}').fadeOut();render_request();"
  end

  def notifying_records_request
    un_ids = params[:unnotified_id].split(",")
    un_ids.each do |rr_request|
      request = RecordsRequest.find(rr_request)
      request.update_attributes(:notified_status => true)
    end
    render :nothing => true
  end

  def notifying_msg
    un_ids = params[:unnotified_msg_id].split(",")
    un_ids.each do |msg|
      message = Message.find(msg)
      message.update_attributes(:notified_status => true)
    end
    render :nothing => true
  end

  def render_request
    render_request = RecordsRequest.where(" approved_status = 0 ").limit(5).order("created_at desc")
    render_request = render_request.map{|m| {:rr_type => Record.find(m.record_id).rr_type , :data => Record.find(m.record_id).data , :host => Record.find(m.record_id).host.combine , :user => User.find(m.user_id).username , :request_id => m.id, :created_at => m.created_at.to_s.gsub(/\D/, "")} }
    render :json => render_request
  end

  def render_msg
    # render_msg = Message.where(:receiver_id => params[:receiver_id]).limit(4).order("created_at desc")
    render_msg = current_user.received_messages.limit(4).order("created_at desc")
    render_msg = render_msg.map{|m| {:sender => User.find(m.sender_id).username , :msg => m.msg , :state => m.state , :sender => User.find(m.sender_id).username } }
    render :json => render_msg
  end

  def unnotify_request_check
    unnotify_status = RecordsRequest.where(" notified_status = false ").order("updated_at")
    unnotify_status = unnotify_status.map{|m| {:record_id => m.record_id , :user_id => m.user_id, :id => m.id } }
    render :json => unnotify_status
  end

  def unnotify_msg_check
    unnotify_msg_status = current_user.received_messages.where(:notified_status => false)
    unnotify_msg_status = unnotify_msg_status.map{|m| {:id => m.id} }
    render :json => unnotify_msg_status
  end

  def index
    #Admin suppose can see all?
    #@zones = current_user.zones
    #@zones = Zone.all
    #@zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
    #@zone = @zones.find{|x| x.zone_name.eql?url2domain(params[:zone_id]) }
    get_zones_and_zone params[:zone_id]
    if @zone.present?
      if @zone.zone_type == "slave"
        #@hosts = @zone.hosts.page(params[:page])
        @records = @zone.slave_records.page(params[:page]).per_page(15)
      else
        @hosts = @zone.hosts.includes(:records).limit(1)
        #.page(params[:page]).per_page(100)
        #.includes(:records)
      end
    else
      # redirect_to n_zones_path
    end
  end

  def show
    get_zones_and_zone params[:zone_id]
    #@host = Host.find_by_combine_and_zone_id(url2domain(params[:id]), @zone.id)
    @host = Host.find_by_combine(url2domain(params[:id]))
  end

  def new
    @host = Host.new
    @zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @host }
      format.js { }
    end
  end

  # GET /hosts/1/edit
  def edit
    @host = Host.find_by_combine(url2domain(params[:id]))
  end

  # POST /hosts
  # POST /hosts.json
  def create
	  @host = Host.new(params[:host])
	  @host.user_id = current_user.id
	  @host.typ = 1
	  @host.status = 1
	  #@host.remote_addr = request.remote_addr
	  #@host.reference = @host.domain
	  @host.reference2 = @host.subdomain
	  @host.combine = "#{params[:host][:subdomain]}.#{params[:host][:reference]}"
	  #@record.rr_zone =
	  #session[:authenticity_token] = nil
	  @zone = Zone.find(params[:host][:zone_id])
	  #unless current_user.hosts.find_by_zone_id(params[:host][:zone_id]).nil? 
	      @hosts = Host.where(:user_id => current_user.id,:zone_id => params[:host][:zone_id]).includes(:records).limit(1)
        #page(params[:page]).per_page(100)
	      if @host.save
	         #@notice = 'Host has been created successfully!'
	         @notice = 'Host was successfully created!'
	         #render 'create.js'
	         #format.js { }
	      else
	        #flash[:notice] = 'Error! Cannot create host!'
          #@errors = @host.errors.full_messages
          @errors = []
          @host.errors.each {|x| @errors << @host.errors[x]}
	        #@errors = @host.errors[]
          render 'create_error.js'
	        #format.js { }
	      end    
	  #end
  end

  # PUT /hosts/1
  # PUT /hosts/1.json
  def update
    @host = Host.find_by_combine(url2domain(params[:id]))
    respond_to do |format|
      if @host.update_attributes(params[:host])
        format.js { render 'update.js' }
        format.html { redirect_to @host, notice: 'Host was successfully updated.' }
        format.json { head :ok }
      else
        @errors = @host.errors.full_messages
        format.js { render 'error.js' }
        format.html { render action: "edit" }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hosts/1
  # DELETE /hosts/1.json
  def destroy
    @host = Host.find_by_combine(url2domain(params[:id]))

    records = Record.find_all_by_host_id(@host.id)
    unless records.nil?
      delete_myrecord(records, @host.id)
    end

    @zone = @host.zone
    @host.destroy
    @hosts = Host.where(:user_id => current_user.id,:zone_id => @zone.id)

    @notice = 'Host was successfully deleted!'
    respond_to do |format|
      format.html { redirect_to zone_hosts_path(domain2url(@zone.zone_name)) }
      format.json { head :ok }
      format.js {}
    end
  end
  
  def rr_edit
    @zone = Zone.find(params[:zone_id])
    @record = Record.find(params[:record_id])
    # @record = eval("Record#{params[:record][:rr_type].capitalize}.find(#{params[:record_id]})")
    @host = Host.find(params[:id])
    if @host.active?
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
        render "records/#{params[:rr_type].downcase}"
      else
        render "records/others"
      end
   else
      render :js => "show_error(['Unable to edit. Host is inactive.'])"
    end
  end

  #Amir - more sutaible rr_update
  def rr_save

    available_rr_type = ["A","MX", "AAAA", "TXT", "CNAME", "NS", "PTR", "SRV"]
    if !(available_rr_type.find_all{|x| x == params[:record][:rr_type]}.empty?) && params[:from] != "others"
      logger.debug "atas"
      @record = eval("Record#{params[:record][:rr_type].capitalize}.find(#{params[:record_id]})")
      # logger.debug "### Record#{params[:record][:rr_type].capitalize}.find(#{params[:record_id]})"
    else
      logger.debug "bawah"
      @record = RecordOthers.find(params[:record_id])
    end

    a = params[:record][:rr_host].split(".")
    b = params[:record][:rr_zone].split(".")
    b.size.times {a.pop}
    
    if a.empty?
      params[:record][:rr_host] = "@"
    else
      params[:record][:rr_host] = a.join(".")
    end

    #if update remove the old data, compare
    tmp_ttl = @record.ttl
    tmp_data = @record.data
    tmp_rr_type = @record.rr_type
    tmp_active = @record.active

    if @record.update_attributes(params[:record])

      #prev_tmp = [tmp_ttl, tmp_data, tmp_rr_type]
      #new_tmp = [@record.ttl, @record.data, @record_rr_type]

      unless (tmp_ttl == @record.ttl) && (tmp_data == @record.data) && (tmp_rr_type == @record.rr_type) 
        fqdn = (@record.rr_host == "@") ? "#{@record.rr_zone}" : "#{@record.rr_host}.#{@record.rr_zone}"
        n = Dnscell::Nsupdate.new(@record.host.zone_id, current_user.id, fqdn)
        n.delete_common tmp_data, tmp_rr_type
        n.send

        if @record.active
          Resque.enqueue(CreateRecordApplication, @record.id, current_user.id)
        end
      else
        unless tmp_active == @record.active
          if @record.active
            Resque.enqueue(CreateRecordApplication, @record.id, current_user.id)
          else
            Resque.enqueue(InactiveRecordApplication, @record.id, current_user.id)
          end
        end
      end

      if params[:from] == "resource_records"
        render :js => "window.location = '#{resource_records_zone_host_path(:id => domain2url(Host.find(params[:id]).combine),:zone_id => domain2url(Zone.find(params[:zone_id]).zone_name))}'"
      else
        render :js => "$('#dttb_host').dataTable().fnDraw(false);$('#new_host_dialog').dialog('close');show_flash('Record saved.')"
      end
    else
      @error = @record.errors.full_messages
      render 'error.js'
    end
  end

  def resource_records
    get_zones_zone_host_records_record params[:zone_id], params[:id]
    if params[:add].blank?
        if current_user.role?
          redirect_to domains_path
        end
    else
        case params[:add]
        when "A"
          @record = RecordA.new
          @record.rr_type = "A"
          render 'records/a.js'
        when "AAAA"
          @record = RecordAaaa.new
          @record.rr_type = "AAAA"
          render 'records/aaaa.js'
        when "TXT"
          @record = RecordTxt.new
          @record.rr_type = "TXT"
          render 'records/txt.js'
        when "CNAME"
          @record = RecordCname.new
          @record.rr_type = "CNAME"
          render 'records/cname.js'
        when "MX"
          @record = RecordMx.new
          @record.rr_type = "MX"
          render 'records/mx.js'
        when "NS"
          @record = RecordNs.new
          @record.rr_type = "NS"
          render 'records/ns.js'
        when "PTR"
          @record = RecordPtr.new
          @record.rr_type = "PTR"
          render 'records/ptr.js'
        when "SRV"
          @record = RecordSrv.new
          @record.rr_type = "SRV"
          render 'records/srv.js'
        when "Others"
          @record = RecordOthers.new
          @record.rr_type = ""
          render 'records/others.js'
        else 
          render 'hosts/rr/resource_records'
        end
    end
    # render 'hosts/rr/resource_records'
  end

  def rr_create
    #construct_host = params[:record][:rr_host].split(".") - params[:record][:rr_zone].split(".")
    case params[:resource]
    when "A"
      params[:record] = params[:record_a]
      @record = RecordA.new(params[:record])
    when "AAAA"
      params[:record] = params[:record_aaaa]
      @record = RecordAaaa.new(params[:record])
    when "CNAME"
      params[:record] = params[:record_cname]
      @record = RecordCname.new(params[:record])
    when "TXT"
      params[:record] = params[:record_txt]
      @record = RecordTxt.new(params[:record])
    when "MX"
      params[:record] = params[:record_mx]
      @record = RecordMx.new(params[:record])
    when "NS"
      params[:record] = params[:record_ns]
      @record = RecordNs.new(params[:record])
    when "PTR"
      params[:record] = params[:record_ptr]
      @record = RecordPtr.new(params[:record])
    when "SRV"
      params[:record] = params[:record_srv]
      @record = RecordSrv.new(params[:record])
    when "Others"
      params[:record] = params[:record_others]
      @record = RecordOthers.new(params[:record])
    else
      @record = Record.new(params[:record])
    end

    a = params[:record][:rr_host].split(".")
    b = params[:record][:rr_zone].split(".")
    b.size.times {a.pop}

    @record.user_id = current_user.id

    if a.empty?
      @record.rr_host = "@"
    else
      @record.rr_host = a.join(".")
    end
    @record.host_id = params[:record][:host_id]
    
    if current_user.role == false 
      admin_rr_save
    else
      user_rr_save
    end
  end

  def user_rr_save
    @record.approval_state = get_user_domain_by_url2domain(Host.find(params[:record][:host_id]).share_scope).approval 
    logger.debug "approaval state #{@record.approval_state}"
    @record.active = @record.approval_state ? false : true
    if @record.save
      if @record.approval_state # require approval
        RecordsRequest.create(:user_id => current_user.id, :record_id => @record.id) 
        @notice = "Record creation has been requested."
      else
        Resque.enqueue(CreateRecordApplication, @record.id, current_user.id)
        write_msg current_user.id, 1, "#{current_user.username} [Add #{@record.rr_type} #{@record.data} INTO #{@record.host.combine}] #{Time.now}.", params[:state]
        @notice = "Record creation has been created."
      end
      get_zones_zone_host_records_record params[:record][:zone_id_param], params[:record][:host_id_param]
      render 'records/create.js'
    else
      get_zones_zone_host_records_record params[:record][:zone_id_param], params[:record][:host_id_param]
      @errors = []
      @record.errors.each {|x| @errors << @record.errors[x]}
      render 'hosts/create_error.js'
    end
  end

  def admin_rr_save
  	
    if @record.save
      if @record.active
        Resque.enqueue(CreateRecordApplication, @record.id, current_user.id)
      end
      get_zones_zone_host_records_record params[:record][:zone_id_param], params[:record][:host_id_param]
      @notice = "Record was successfully created"
      render 'records/create.js'
    else
      get_zones_zone_host_records_record params[:record][:zone_id_param], params[:record][:host_id_param]
      @errors = []
      @record.errors.each {|x| @errors << @record.errors[x]}
      render 'hosts/create_error.js'
    end
  end


  def rr_remove
    record = RecordDelete.find(params[:record_id])
    id = domain2url(record.host.combine)
    if record.update_attributes(:delete_state => true)
      @record = record
      get_zones_zone_host_records_record params[:zone_id], params[:id]
      @hosts = Host.where(:zone_id => @zone.id)
      Resque.enqueue(DeleteRecordApplication, record.id, current_user.id)
      Host.decrement_counter(:records_count, record.host_id)
      @notice = "Record was deleted!"
      render "records/destroy.js"
    else
      @notice = "Something wrong with your transaction"
      render "records/destroy.js"
    end
    #id = domain2url(@record.host.combine)
    #Resque.enqueue(DeleteRecordApplication, @record.data, @record.rr_type, @record.rr_zone, @record.host.combine)
    #@record.destroy
    #redirect_to resource_records_zone_host_path(:id=>id)
  end
  
  def delete_hosts
    unless params[:host_ids].nil?
      params[:host_ids].each do |x|
        records = Record.find_all_by_host_id(x)
        unless records.nil?
          delete_myrecord(records, x)
        end
      end

      if Host.delete(params[:host_ids])
        @notice = 'Host(s) has been deleted successfully!'
      else
        #@notice = 'Something wrong? please contact administrator'
      end
    else
      @notice = 'Nothing to delete'
    end
          #redirect_to domain_path(:id => params[:id])
    #@domain = params[:id]
    #@hosts = Host.find_all_by_identifier(params[:id])
    @zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
    @hosts = Host.where(:user_id => current_user.id, :zone_id => @zone.id)
    #@hosts = Host.find_by_zone_id(zone_id)
    #render 'destroy.js'
  end

  def get_zones_zone_host_records_record zone_id, host_id
    get_zones_and_zone zone_id
    @host = Host.find_by_combine_and_zone_id(url2domain(host_id), @zone.id)
    @records = @host.records.exclude_delete
  end

  def delete_myrecord(obj_delete, host_id)
    data = Array.new
    host = Host.find(host_id)
    obj_delete.each do |x|
      record = Record.find(x)
      data << [record.data, record.rr_type]
      record.destroy
    end
    Resque.enqueue(DeleteRecordsApplication, data, current_user.id, host.zone.id, host.combine)
  end

  def logs
    get_zones_zone_host_records_record params[:zone_id], params[:id]
    @histories = History.where(:host => url2domain(params[:id]),  :zone_id => @zone.id)
  end

  def shares
    get_zones_zone_host_records_record params[:zone_id], params[:id]
  end

end
