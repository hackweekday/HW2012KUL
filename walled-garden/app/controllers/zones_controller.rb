class ZonesController < ApplicationController
  set_tab :zone_management
  set_tab :zones, :first_level
  set_tab :host, :second_level
  set_tab :soa, :second_level, :only => %w(soa soa_edit soa_update)
  set_tab :ns, :second_level, :only => %w(ns)
  set_tab :zone_file, :second_level, :only => %w(zone_file)
  set_tab :options, :second_level, :only => %w(options)
  set_tab :general, :second_level, :only => %w(general)
  set_tab :graph, :second_level, :only => %w(graph)
  set_tab :logs, :second_level, :only => %w(logs)
  set_tab :more, :second_level, :only => %w(share nodes)
  set_tab :dnssec, :second_level, :only => %w(dnssec dnssec_child dnssec_child_check dnssec_keys dnssec_sign dnssec_ds dnssec_dnskey)
  set_tab :keys, :third_level, :only => %w(dnssec_keys)
  set_tab :ds, :third_level, :only => %w(dnssec_ds)
  set_tab :dnskey, :third_level, :only => %w(dnssec_dnskey)
  set_tab :child, :third_level, :only => %w(dnssec_child dnssec_child_check)

  def get_paginated_log
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    case params[:iSortCol_0]
    when "6"
      sort_variable = "created_at #{params[:sSortDir_0]}"
    end
    if params[:host_name] != nil
      host = url2domain(params[:host_name])
    else
      host = url2domain(params[:id])
    end
      @histories = History.joins(:user).where("(serial like ? or username like ? or host like ? or resource_record like ? or data like ? or histories.created_at like ?) AND histories.#{params[:host_name].nil? ? "zone" : "host"} = ? AND resource_record <> 'SOA'", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%", host).order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      @histories_count = @histories.count
  end

  def dnssec
    get_zones_and_zone params[:id]
    unless @zone.zone_type == "slave"
      unless @zone.dnssec
        render 'dnssec'
      else
        #render 'dnssec_signed'
        redirect_to dnssec_keys_zone_path
      end
    else
      render :text => "Slave will help you"
    end
  end

  def dnssec_sign
    get_zones_and_zone params[:id]
    dnssec = params[:dnssec]
    policy = params[:policy]
    if dnssec
      @zone.update_attributes(:dnssec => true)
      if policy == "1"
        t = Time.now
        date_today = t.strftime("%Y-%m-%d")
        FileUtils.rm_r Dir.glob("#{ETC_DIR}production/keys/default/#{@zone.zone_name}/*")
        Dnscell::Dnssec.generate_default_keys @zone.zone_name, date_today, @zone.id
        Dnscell::Rndc.new.sign @zone.zone_name
        redirect_to dnssec_zone_path, :notice => "Zone #{@zone.zone_name} has been signed with DNSSEC"
      end
      #render :text => policy
    else
      render :text => "prob"
    end

  end

  def dnssec_keys
    #do we need to store the key information in the DB?
    get_zones_and_zone params[:id]
    unless @zone.dnssec
      redirect_to dnssec_zone_path
    end
    #@keys = Dnscell::Dnssec.get_keys_info @zone.zone_name
    @zone_keys = @zone.zone_keys
  end

  def dnssec_ds
    get_zones_and_zone params[:id]
    unless @zone.dnssec
      redirect_to dnssec_zone_path
    end
  end

  def dnssec_dnskey
    get_zones_and_zone params[:id]
    unless @zone.dnssec
      redirect_to dnssec_zone_path
    end
  end

  def dnssec_key_new
    get_zones_and_zone params[:id]
    unless @zone.dnssec
      redirect_to dnssec_zone_path
    end
    @zone_key = ZoneKey.new
    @zk = ZoneKey.where(:zone_id => @zone.id, :key_type => params[:type]).first
    #suppose to get from policy setting
    @zone_key.key_size = @zk.key_size
    @zone_key.key_algorithm = @zk.key_algorithm
    @zone_key.publish = "none"
    @zone_key.activate = "none"
    @zone_key.revocation = "none"
    @zone_key.inactivation = "none"
    @zone_key.deletion = "none"
    @zone_key.key_type = params[:type]
  end

  def dnssec_key_create
    get_zones_and_zone params[:id]

    if params[:zone_key][:publish] == "none"
      params[:zone_key][:publish] = nil
    end

    if params[:zone_key][:activate] == "none"
      params[:zone_key][:activate] = nil
    end

    if params[:zone_key][:revocation] == "none"
       params[:zone_key][:revocation] = nil
    end

    if  params[:zone_key][:inactivation] == "none"
       params[:zone_key][:inactivation] = nil
    end

    if  params[:zone_key][:deletion] == "none"
       params[:zone_key][:deletion] = nil
    end

    p = params[:zone_key][:publish]
    a = params[:zone_key][:activate]
    r = params[:zone_key][:revocation]
    i = params[:zone_key][:inactivation]
    d = params[:zone_key][:deletion]
    type = params[:zone_key][:key_type]
    algorithm = params[:zone_key][:key_algorithm]
    size = params[:zone_key][:key_size]
    params[:zone_key][:zone_id] = @zone.id

    @zone_key = ZoneKey.new(params[:zone_key])

    if @zone_key.save
      Dnscell::Dnssec.generate_key type, size, algorithm, p, a, r, i, d, @zone_key.id
      # redirect_to dnssec_zone_path
      @zone_keys = @zone.zone_keys
      render 'dnssec_key_refresh.js'
    else
      @errors = []
      @zone_key.errors.each {|x| @errors << @zone_key.errors[x]}
      render 'error.js' 
      #render 'dnskey_key_create'
    end
    #-P -A -R -I -D
  end

  def dnssec_key_edit
    get_zones_and_zone params[:id]
    @zone_key = ZoneKey.find(params[:zone_key_id])
    if @zone_key.publish.blank?
      @zone_key.publish = "none"
    end
    if @zone_key.activate.blank?
      @zone_key.activate = "none"
    end
    if @zone_key.revocation.blank?
      @zone_key.revocation = "none"
    end
    if @zone_key.inactivation.blank?
      @zone_key.inactivation = "none"
    end
    if @zone_key.deletion.blank?
      @zone_key.deletion = "none"
    end

    render 'dnssec_key_new'
  end

  def dnssec_key_update
    get_zones_and_zone params[:id]

    if params[:zone_key][:publish] == "none"
      params[:zone_key][:publish] = nil
    end

    if params[:zone_key][:activate] == "none"
      params[:zone_key][:activate] = nil
    end

    if params[:zone_key][:revocation] == "none"
       params[:zone_key][:revocation] = nil
    end

    if  params[:zone_key][:inactivation] == "none"
       params[:zone_key][:inactivation] = nil
    end

    if  params[:zone_key][:deletion] == "none"
       params[:zone_key][:deletion] = nil
    end

    p = params[:zone_key][:publish]
    a = params[:zone_key][:activate]
    r = params[:zone_key][:revocation]
    i = params[:zone_key][:inactivation]
    d = params[:zone_key][:deletion]

    @zone_key = ZoneKey.find(params[:zone_key_id])

    if @zone_key.update_attributes(params[:zone_key])
      Dnscell::Dnssec.update_key p, a, r, i, d, @zone_key.id
      # redirect_to dnssec_zone_path
      @zone_keys = @zone.zone_keys
      render 'dnssec_key_refresh.js'
    else
      #render :text => "Whoaa!!!"
     
      @errors = []
      @zone_key.errors.each {|x| @errors << @zone_key.errors[x]}
      #@errors.pop
       Rails.logger.auto_flushing = true
      Rails.logger.info "#{@errors}\n"
      render 'error.js' 
    end

  end

  def dnssec_delete_key
    get_zones_and_zone params[:id]
    @zone_key = ZoneKey.find(params[:zone_key_id])
    @zone_key.destroy
    #Delete the key
    FileUtils.rm_r Dir.glob("#{ETC_DIR}production/keys/default/#{@zone.zone_name}/#{@zone_key.key_file_tag}*")
    redirect_to dnssec_zone_path
  end

  def dnssec_unsign
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    zone_id = @zone.id
    @zone.update_attributes(:dnssec => false)
    
    Resque.enqueue(UnsignZoneApplication, zone_id, current_user.id)
    redirect_to dnssec_zone_path, :notice => "Zone #{@zone.zone_name} has been unsigned"
  end

  def dnssec_child
    get_zones_and_zone params[:id]
    @childs = @zone.records.where(:rr_type=>"NS").where(["rr_host NOT IN (?)", ["@"]])
  end
    
  def dnssec_child_check
    get_zones_and_zone params[:id]
    @h = Host.find params[:h]
    @zone_delegation_signers = Dnscell::Dnssec.get_ds_all(@h.combine)
  end

  def dnssec_delete_ds
    get_zones_and_zone params[:id]
    zds_id = params[:zds]
    z = ZoneDelegationSigner.find zds_id
    unless z.nil?
      record = z.host.record_deletes.where(:data => z.data).first
      if record.update_attributes(:delete_state => true)
        #Delete unwanted DS record(s) from zone
        Resque.enqueue(DeleteRecordApplication, record.id, current_user.id)
        Host.decrement_counter(:records_count, record.host_id)
      end
      z.delete
      redirect_to dnssec_child_zone_path, :notice => 'DS successfull deleted'
    else
      redirect_to dnssec_child_zone_path, :notice => 'Somethin wrong'
    end
  end

  def dnssec_child_update
    get_zones_and_zone params[:id]
    unless params[:ds_tags].nil?    
      #Delete unwanted DS
      #tags_to_exclude = params[:zone_tags].collect!{|x| x.split("-")[0]}
      tags_to_exclude = params[:ds_tags]
      zone_delegation_signers_table = Arel::Table.new(:zone_delegation_signers)
      zds = ZoneDelegationSigner.where(zone_delegation_signers_table[:key_tag].not_in tags_to_exclude)
      unless zds.empty?
        #zds.delete_all
        zds.each do |z|
          record = z.host.record_deletes.where(:data => z.data).first
          if record.update_attributes(:delete_state => true)
            #Delete unwanted DS record(s) from zone
            Resque.enqueue(DeleteRecordApplication, record.id, current_user.id)
            Host.decrement_counter(:records_count, record.host_id)
          end
        end
        zds.delete_all
      end
      
      #rr_zone: dnssec.kpkk.gov.my. 
      #ttl: 86400
      #host_id: params[:h]
      #read_only: true 
      #user_id: current_user.id
      #rr_type: DS 
      #data: 14490 7 2 780AB01CDD97C0A9D4989EB7CB10276517F9ACFC52A5FB8AFC823B1800D4D73C
      host = Host.find(params[:h])
      zone_delegation_signers = Dnscell::Dnssec.get_ds_all(host.combine)
      #ds.split(";")[0].split(" ")[3..7].join(" ")
      params[:ds_tags].each do |x|
        # x format tag-digest = 43544-2
        hds = Array.new
        babble = ""
        zone_delegation_signers.each do |ds|
          d = ds.split(";")[0].split(" ")
          babble = ds.split(";")[1]
          #<%=ds.split(";")[0].split(" ")[4]%>-<%=ds.split(";")[0].split(" ")[6]%>
          key_tag = "#{d[4]}-#{d[6]}"
          if key_tag == x
            hds = d
          end
        end

        

        ds_check = ZoneDelegationSigner.find_by_key_tag(x)

        #------ data for ZoneDelegation
        if ds_check.nil?
          record = RecordDs.new(:host_id => params[:h], :user_id => current_user.id, :read_only => true,
          :rr_zone => host.zone.zone_name, :rr_host => host.subdomain, :ttl => hds[1],
          :rr_type => hds[3], :data => hds[4..7].join(" "))
          record.save
          #Create pls
          Resque.enqueue(CreateRecordApplication, record.id, current_user.id)

          ds = ZoneDelegationSigner.new(:host_id => params[:h], :ttl => hds[1], 
          :key_tag => x, :algorithm => hds[5], :digest_type => hds[6], :digest => hds[7],
          :babble => babble, :data => hds[4..7].join(" "))

          ds.save
        end
        #------------------------------
        
        # Check if exist in database just exclude.

      end
      redirect_to dnssec_child_zone_path, :notice => 'DS successfull included'
    else
      redirect_to dnssec_child_zone_path, :notice => 'Nothing to include'
    end
  end

  def zone_node_delete
    zn = ZoneNode.find(params[:zone_nodes_id])
    zn.destroy
    render :js => "show_flash('Node has been deleted.');$('#zone_nodes_dttb').dataTable().fnDraw(false)"
  end

  def add_zone_node
    node = Node.find(params[:node_id])
    check = NodeCheck.new(:ip_address => node.ip_address, :node_serial => node.node_serial, :auth_token => node.auth_token)
    logger.debug "#{check.valid?}"
    if check.valid?
      #curl -d "zone_name=bad.com&node_id=38" 
      #"http://192.168.118.1:4000/api/v1/create/slave.json?
      #auth_token=V5tzFwAxoEwzpRZBjRzr"
      url = "http://#{node.ip_address}:#{NODE_PORT_TWO}/api/v1/create/slave.json?auth_token=#{node.auth_token}"
      response = Typhoeus::Request.post(url, :params => {:zone_name => url2domain(params[:id]), :node_id => node.remote_id} )
      @zone = Zone.find_by_zone_name(url2domain(params[:id]))
      @zone.zone_nodes.create(:node_id => params[:node_id])
      @zone.update_attributes(:allow_transfer => 1, :also_notify => 1)
      #Create the IP pool
      @zone.zone_opt_ips.create(:typ => "allow-transfer", :allow => true, :ip_address => node.ip_address)
      @zone.zone_opt_ips.create(:typ => "also-notify", :allow => true, :ip_address => node.ip_address)
      Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
      render :js => "hide_errors();$('#select_node_form').dialog('close');show_flash('Node has added.');$('#zone_nodes_dttb').dataTable().fnDraw(false)"
    else
      @errors = []
      check.errors.each {|x| @errors << check.errors[x]}
      render 'error.js'
    end
  end

  def get_log
    get_zones_and_zone params[:id]
    @histories = History.where(:zone => url2domain(params[:id]), :zone_id => @zone.id).limit(100)
  end

  def get_paginated_zone_nodes
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    case params[:iSortCol_0]
    when "0"
      sort_variable = "created_at desc"
    when "1"
      sort_variable = "node_name #{params[:sSortDir_0]}"
    when "2"
      sort_variable = "created_at #{params[:sSortDir_0]}"
    end
      @zone.zone_type == "slave" ? (node_type = "primary") : (node_type = "secondary")
      @nodes = @zone.nodes.where("node_name LIKE ? AND node_type = '#{node_type}'", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      @unassigned_nodes = @zone.zone_nodes.empty? ? Node.where("status = 1 AND node_type = 'secondary'") : Node.where("status = 1 AND node_type = 'secondary' AND id not in (?)", @zone.zone_nodes.map{|zn| zn.node_id })
  end

  def get_paginated_hosts
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    case params[:iSortCol_0]
    when "0"
      sort_variable = "created_at desc"
    when "1"
      sort_variable = "combine #{params[:sSortDir_0]}"
    when "2"
      sort_variable = "created_at #{params[:sSortDir_0]}"
    end
      if params[:sSearch] == url2domain(params[:id])
        @hosts = Zone.find_by_zone_name(url2domain(params[:id])).hosts.where("combine = ?", url2domain(params[:id])).paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      else
        @hosts = Zone.find_by_zone_name(url2domain(params[:id])).hosts.where("combine LIKE ?", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength]).without_destroy_state
      end
      @hosts_count = @hosts.count
      @from = "admin"
  end

  def master_identified
    master = Master.find_by_ip_address(params[:master])
    if master != nil
      if master.tsig
        @master = master.id
        @status = 'tsig'
        @tsig = master.tsig
      else
        @master = master.id
        @status = 'no_tsig'
      end
    else
        @status = 'none'
    end
  end

  def index
    #@zone = current_user.zones.first
    @zone = Zone.order("position").first
    if @zone.present?
      #redirect_to zone_hosts_path(domain2url(@zone.zone_name))
      redirect_to general_zone_path(domain2url(@zone.zone_name))
    else
      redirect_to n_zones_path + '/1/start'
    end
  end

  def show
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    #handle error
    unless @zone.nil?
      respond_to do |format|
        format.html
        format.json { render json: @zone }
      end
    else
      redirect_to zones_path
    end
  end

  def soa
    get_zones_and_zone params[:id]
    @soa = Soa.find_by_zone_id(@zone.id)
    #unless @soa.present?
    #  @soa = Soa.new
    #end
  end

  def soa_edit
    get_zones_and_zone params[:id]
    @soa = Soa.find_by_zone_id(@zone.id)
    @email = Dnscell::Utils.admin_email
    @primary = Dnscell::Utils.primary_ns @zone.id
  end

  def soa_update
      get_zones_and_zone params[:id]
      @soa = Soa.find(params[:soa][:id])

      if params[:soa][:use_default_primary] == "1"
        @soa.primary = Dnscell::Utils.primary_ns @zone.id 
      else
        @soa.primary = params[:soa][:primary]
      end

      if params[:soa][:use_default_email] == "1"
        @soa.email = Dnscell::Utils.admin_email
      else
        @soa.email = params[:soa][:email]
      end 

      @soa.soattl_seconds = params[:soa][:soattl_seconds]
      @soa.refresh_weeks = params[:soa][:refresh_weeks]
      @soa.refresh_days = params[:soa][:refresh_days]
      @soa.refresh_hours = params[:soa][:refresh_hours]
      @soa.refresh_minutes = params[:soa][:refresh_minutes]
      @soa.refresh_seconds = params[:soa][:refresh_seconds]
      @soa.retry_weeks = params[:soa][:retry_weeks]
      @soa.retry_days = params[:soa][:retry_days]
      @soa.retry_hours = params[:soa][:retry_hours]
      @soa.retry_minutes = params[:soa][:retry_minutes]
      @soa.retry_seconds = params[:soa][:retry_seconds]
      @soa.expiry_weeks = params[:soa][:expiry_weeks]
      @soa.expiry_days = params[:soa][:expiry_days]
      @soa.expiry_hours = params[:soa][:expiry_hours]
      @soa.expiry_minutes = params[:soa][:expiry_minutes]
      @soa.expiry_seconds = params[:soa][:expiry_seconds]
      @soa.minimum_weeks = params[:soa][:minimum_weeks]
      @soa.minimum_days = params[:soa][:minimum_days]
      @soa.minimum_hours = params[:soa][:minimum_hours]
      @soa.minimum_minutes = params[:soa][:minimum_minutes]
      @soa.minimum_seconds = params[:soa][:minimum_seconds]
      @soa.use_default_primary = params[:soa][:use_default_primary]
      @soa.use_default_email = params[:soa][:use_default_email]
      #@soa.update_attributes(params[:soa])
      if @soa.changed?
        @soa.user_id = current_user.id
        if @soa.save
          redirect_to soa_zone_path, notice: "SOA was successfully updated."
        else
          @email = Dnscell::Utils.admin_email
          @primary = Dnscell::Utils.primary_ns @zone.id
          render 'soa_edit'
        end
      else
        redirect_to soa_zone_path, notice: "No changes found."
      end
  end

  def ns
    get_zones_and_zone params[:id]
    @primary = ZoneNameServer.where(:zone_id => @zone.id, :primary => true)
    @slaves = ZoneNameServer.where(:zone_id => @zone.id, :primary => false)
    #get_zones_and_zone params[:id]
    #@name_servers = @zone.name_servers
    #@name_servers = @zone.hosts.first.records.where(:rr_type => "NS")
    #@primaries = @zone.name_servers.where(:p_or_s => 0)
    #@secondaries = @zone.name_servers.where(:p_or_s => 1)
  end

  def new
    @zone = Zone.new
  end

  def n
    id = [1,2,3]
    if id.include? params[:id].to_i
      @template_option = Template.all.map{|x| [x.name,x.id] }
      logger.debug "%%%% #{@template_option}"
      render :layout => 'application_without_sidebar'
      @zone = Zone.new
    else
      redirect_to n_zones_path + '/1/start'
    end
  end

  def edit
    @zone = Zone.find(params[:id])
  end

  def create
    @zone = Zone.new(params[:zone])
    @zone.allow_query = 1
    @zone.template_id = params[:template_id]
    if @zone.save
      ZoneOptIp.create(:zone_id => @zone.id, :ip_address => "any", :status => 1, :read_only => 0, :allow => 1, :typ => "allow-query")
      render :js => "window.location = '#{zones_path}'" if params[:zone][:zone_type] == "slave"
      #To be removed
      #if @zone.ns == '1'
      #  NameServer.create(:ns => "ns1." + @zone.zone_name,:zone_id => @zone.id, :ip => "1.1.1.1", :ipv6 => "", :p_or_s => "0") #require interface IP
      #else
      #  nameserver = NameServer.where(:go => 1,:p_or_s => 0).first.ns
      #  NameServer.create(:ns => nameserver,:zone_id => @zone.id, :ip => "1.1.1.1", :ipv6 => "", :p_or_s => "0")
      #  NameServer.where(:go => 1, :p_or_s => 1).each do |ns|
      #  NameServer.create!(:ns => ns.ns,:zone_id => @zone.id, :ip => ns.ip, :ipv6 => ns.ipv6, :p_or_s => "1")
      #end
      #end
      if params[:action] == "n"
          redirect_to zone_hosts_path(domain2url(params[:zone][:zone_name]))
      end
      Resque.enqueue(CreateZoneApplication, @zone)
      flash[:notice] = 'Zone was successfully created!'
    else
      render 'create_error.js'
    end
  end

  def update
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    if @zone.update_attributes(params[:zone])
      Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
      case params[:m]
      when "2"
        @notice = "TSIG Successfully saved!"
        render 'opt_allow.js'
      end
    else
      @error = @zone.errors.full_messeges
      render 'error.js'
    end
  end

  def destroy
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @zone.destroy
    Resque.enqueue(DeleteZoneApplication, @zone.zone_name, @zone.zone_type)
    flash[:notice] = 'Zone was successfully deleted!'
    self.index
  end

  def zone_file
    get_zones_and_zone params[:id]
  end

  def options
    get_zones_and_zone params[:id]
    case @zone.zone_type
    when "slave"
      @master = @zone.server
    end
    case @zone.also_notify
    when 1
      @an_ips = @zone.zone_opt_ips.where(:typ => "also-notify").order("position")
      @an_partial = "zones/zone_opt/ip_ls"
      @ip = ZoneOptIp.new
      @ip.typ = "also-notify"
    end # End case @zone.also_notify
    case @zone.allow_update
    when 1
      @au_ips = @zone.zone_opt_ips.where(:typ => "allow-update").order("position")
      @au_partial = "zones/zone_opt/ip_ls"
      @ip = ZoneOptIp.new
      @ip.typ = "allow-update"
    when 2 
      @au_partial = "zones/zone_opt/tsig_ls"
    when 3
      @au_acls = @zone.zone_acls.where(:zone_method => "allow-update").order("position")
      @au_partial = "zones/zone_opt/acl_ls"
    end #end case @zone.allow_update
    case @zone.allow_query
    when 1
      @aq_ips = @zone.zone_opt_ips.where(:typ => "allow-query").order("position")
      @aq_partial = "zones/zone_opt/ip_ls"
      @ip = ZoneOptIp.new
      @ip.typ = "allow-query"
    when 3 
      @aq_acls = @zone.zone_acls.where(:zone_method => "allow-query").order("position")
      @aq_partial = "zones/zone_opt/acl_ls"
    end
    case @zone.allow_transfer
    when 1
      @at_ips = @zone.zone_opt_ips.where(:typ => "allow-transfer").order("position")
      @at_partial = "zones/zone_opt/ip_ls"
      @ip = ZoneOptIp.new
      @ip.typ = "allow-transfer"
    when 2 
      @at_partial = "zones/zone_opt/tsig_ls"
    when 3
      @at_acls = @zone.zone_acls.where(:zone_method => "allow-transfer").order("position")
      @at_partial = "zones/zone_opt/acl_ls"
    end
  end

  
  def opt_edit
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    if params[:type] == "master"
      @v = "options"
      @masters = Master.all
      if @zone.server.nil?
        @master = Master.new
      else
        @master = @zone.server
      end
    end
  end
    
   def opt_allow #do display method & its lits
     @zone = Zone.find_by_zone_name(url2domain(params[:id]))
     case params[:t]
     when "allow-transfer"
       @zone.allow_transfer = params[:m].gsub(/true|false|/, 'true' => '1', 'false' => '0')
     when "allow-query"
       @zone.allow_query = params[:m].gsub(/true|false|/, 'true' => '1', 'false' => '0')
     when "allow-update"
       @zone.allow_update = params[:m].gsub(/true|false|/, 'true' => '1', 'false' => '0')
     when "also-notify"
       @zone.also_notify = params[:m].gsub(/true|false|/, 'true' => '1', 'false' => '0')
     end
     if @zone.save
      # render :js => "alert('ok method : #{params[:m]} type : #{params[:t]}')"

      Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
      query_opt_ls params[:t], params[:m]
     else
      render :js => "alert('NO!')"
     end
   end
   
  def opt_create
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @type = params[:t]
    case params[:m]
    when "1"
            @partial = "zones/zone_opt/ip"
            @zone_opt_ip = ZoneOptIp.new(params[:zone_opt_ip])
            @zone_opt_ip.zone_id = @zone.id
            if @zone_opt_ip.save
              Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
              @notice = "IP was successfully created!"
              query_opt_ls @type, "1"
            else
              @error = @zone_opt_ip.errors.full_messages
              render 'zones/zone_opt/opt_error.js'
            end
    when "2"
    when "3"
            @partial = "zones/zone_opt/acl"
            @zone_acl = ZoneAcl.new(params[:zone_acl])
            @zone_acl.zone_id = @zone.id
            @zone_acl.zone_method = @type
            if @zone_acl.save
              Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
              @notice = "IP was successfully created ACL for zone #{@type}!"
              query_opt_ls @type, "3"
            else
              @error = @zone_acl.errors.full_messages
              render 'zones/zone_opt/opt_error.js'
            end
    end
  end
  
  def opt_delete
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @type = params[:t]
    case params[:m]
    when "1"
            if @type == "master"
              @v = params[:v]
              @partial = "zones/zone_opt/master"
            else
              @partial = "zones/zone_opt/ip"
            end
            @zone_opt_ip = ZoneOptIp.find(params[:i])
            if @zone_opt_ip.destroy
              Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
              @notice = "IP successfully deleted for zone #{@type}!"
              @zone_opt_ip = ZoneOptIp.new
              query_opt_ls @type, "1"
            else
              render :js => "alert('no')"
            end
    when "2"
    when "3"
            @partial = "zones/zone_opt/acl"
            @acl = ZoneAcl.find(params[:i])
            if @acl.destroy
              Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
              @notice = "ACL successfully deleted for zone #{@type}!"
              query_opt_ls @type, "3"
            else
              render :js => "alert('no')"
            end
    end
    render 'opt_create.js'
  end

  def tsig_reg
    case params[:s]
    when "reg"
      #resque here
      render :js => "alert('ok, do regen here')"
    else
      render :js => "$('#tsig_form').dialog()"
    end
  end

  def sort_zone
    params[:sidebar_list].each_with_index do |id, index|
      Zone.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
  
  def opt_sort
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @type = params[:t].gsub(/_/,"-")
    case params[:m]
    when '1'
        @partial = "zones/zone_opt/ip"

            params[:ip_list].each_with_index do |id, index|
                ZoneOptIp.update_all(['position=?',index+1], ['id=?', id])
            end
        #@notice = "IP successfully sorted for the zone's #{@type}!"
        query_opt_ls @type, "1"
    when '2'
    when '3'
        params[:acl_list].each_with_index do |id, index|
            ZoneAcl.update_all(['position=?',index+1], ['id=?', id])
        end
        #@notice = "ACL for the zone's #{@type} has been rearranged!"
        @partial = "zones/zone_opt/acl"
        query_opt_ls @type, "3"
    end
    Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
    render 'opt_create.js'
  end

  def get_zone_query_mini_log zone_url, date1, date2
    zone = Zone.find_by_zone_name(url2domain(zone_url))
    if date2.blank?
      @zone_log = []
      query = zone.log_total_zone_queries.select("sum(log_1_count) as sumlog1, sum(log_2_count) as sumlog2, sum(log_3_count) as sumlog3, sum(log_4_count) as sumlog4, sum(log_5_count) as sumlog5, sum(log_6_count) as sumlog6, sum(log_7_count) as sumlog7, sum(log_8_count) as sumlog8, sum(log_9_count) as sumlog9, sum(log_10_count) as sumlog10, sum(log_11_count) as sumlog11, sum(log_12_count) as sumlog12, sum(log_13_count) as sumlog13, sum(log_14_count) as sumlog14, sum(log_15_count) as sumlog15, sum(log_16_count) as sumlog16, sum(log_17_count) as sumlog17, sum(log_18_count) as sumlog18, sum(log_19_count) as sumlog19, sum(log_20_count) as sumlog20, sum(log_21_count) as sumlog21, sum(log_22_count) as sumlog22, sum(log_23_count) as sumlog23, sum(log_24_count) as sumlog24").where("log_date = ?", "#{date1}").first
      (1..24).each do |x|
        @zone_log.push(eval("query.sumlog#{x}.to_i"))
      end
      return @zone_log
    else
      temp2 = []
      date1 = date1.to_date
      date2 = date2.to_date
      day_diff = (date2.to_date - date1.to_date).to_i
      query = zone.log_zone_queries.select("queries_date, sum(queries_count) as count").where("(queries_date <= ? AND queries_date >= ?)", date2.to_s, date1.to_s).group("queries_date")
      logger.debug "HEHEHE #{query}"
      (0..day_diff).each do |d|
        count = 0
        # v = (date1+d).strftime("%Y-%m-%d")
        v = (date1+d)
        temp = query.select{|x| x.queries_date == v}
        unless temp.empty?
          count = temp[0].count.to_i
        end
        temp2.push(count)
      end
      return temp2
    end
    logger.debug "%%% #{@zone_log}"
  end
  
    def get_zone_country_mini_log zone_url, date1, date2
    zone = Zone.find_by_zone_name(url2domain(zone_url))
    if date2.blank?
      logger.debug "&& atas"
      countries = zone.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date = ?", date1.to_s).group("country_code").order("query_sum desc").limit(5).map{|x| [x.country_code, x.query_sum.to_i]}
      return countries
    else
      logger.debug "&& bawah"
      # date2.to_s, date1.to_s
       # "2010-10-06", "2010-10-03"
      countries = zone.log_country_counts.select("country_code, sum(queries_count) as query_sum").where("log_date <= ? AND log_date >= ?", date2.to_s, date1.to_s).group("country_code").order("query_sum desc").limit(5).map{|x| [x.country_code, x.query_sum.to_i]}
      return countries
    end
    logger.debug "%%% #{@zone_log}"
  end


   
  def general
    get_zones_and_zone params[:id]
    unless @zone.nil?
      @single_day = get_zone_query_mini_log params[:id], Date.today.to_s, ''
      @seven_day = get_zone_query_mini_log params[:id], (Date.today-7).to_s , Date.today.to_s
      @thirty_day = get_zone_query_mini_log params[:id], (Date.today-30).to_s , Date.today.to_s

      @single_day_country = get_zone_country_mini_log params[:id], Date.today.to_s, ''
      @seven_day_country = get_zone_country_mini_log params[:id], (Date.today-7).to_s , Date.today.to_s
      @thirty_day_country = get_zone_country_mini_log params[:id], (Date.today-30).to_s , Date.today.to_s

      @date = "2010-10-03"
      gdate = @date.split("-")
      @year = gdate[0]
      @month = gdate[1]
      @day = gdate[2]
      logs = LogZoneQuery.where(:queries_date => @date, :zone_id => @zone.id)
      unless logs.empty?
        @x = Array.new
        logs.each do |log|
          @x << [log.resource, log.queries_count]
        end
      else
          respond_to do |format|
              format.html 
              format.js {render :js => "$('#container').html('No data')"}
            end
      end
    else
      # redirect_to zones_path
    end
  end

  def masters
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    # @masters = ZoneOptIp.where(:zone_id => @zone.id, :typ => "master")
    if @zone.zone_type == "slave"
      @masters = Master.all
      @master = Master.new(:tsig => Tsig.new())
    else
      redirect_to zone_hosts_path(domain2url(@zone.zone_name))
    end
  end

  def save_server
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @zone.server_id = params[:zone][:server_id]
    if @zone.save
      Resque.enqueue(UpdateZoneConfigApplication, @zone.id)
    else
      @error = @zone.errors.full_messages
      render 'error.js'
    end
  end

  def done_create_masters v
      @masters = Master.all
      case v
      when "opt_edit"
        @partial = "zones/zone_opt/master"
        @type = 'master'
        render 'opt_create.js'
      when "masters"
        render :js => "window.location = '#{general_zone_path(domain2url(@zone.zone_name))}'"
      when "new"
        render :js => "window.location = '#{response_policy_zones_path}'"
      end
  end

  def create_masters
    @master = Master.new(params[:master])
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @v = params[:v]
    if params[:master_identified]
      @zone.server_id = params[:master_identified]
      if @zone.save
        # render :js => "alert('#{params[:master_identified]}')"
        @notice = "Master successfully added!"
        @master = @zone.server
        done_create_masters @v
      else
        @error = @zone.errors.full_messages
        render 'error.js'
      end
    else
      if params[:master][:tsig_chk] == "on"
        #  @master = Master.new(:master => params[:master], :tsig => Tsig.new(params[:tsig]))
        @master.tsig = Tsig.new(params[:tsig])
        # @master.tsig.keyword = @zone.zone_name
        # @master.tsig.zone_id = @zone.id
        # unless @zone_tsig.save
        #   err = 1
        #   @error = @zone_opt_ip.errors.full_messages
        # end
      end
      # @master.zone_id = @zone.id
      # @master.typ = "master"
      if @master.save 
        @zone.server_id = @master.id
        @zone.save
        @notice = "Master successfully added!"
        done_create_masters @v
      else
        @error = @master.errors.full_messages
        # @error << @zone_tsig.errors.full_messages
        render 'error.js'
      end
    end
  end

  def new_tsig 
    # render 'zone_tsig_form'
    render :layout => false
  end

  def logs
    get_zones_and_zone params[:id]
    @histories = History.where(:zone => url2domain(params[:id]), :zone_id => @zone.id)
    #@histories = @histories.where(["resource_recor NOT IN (?)", ["SOA"]])
  end

  def share
    get_zones_and_zone params[:id]
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @shares = Share.where(:zone_id => @zone.id)
  end

  def graph
    get_zones_and_zone params[:id]
    #date = "2011-12-07"
    if params[:search_option] == "range"
        s = params[:start_date].split("-")
        @from = "#{s[0].strip}-#{s[1].strip}-#{s[2].strip}"
        @to = "#{s[3].strip}-#{s[4].strip}-#{s[5].strip}"
        f = @from.split("-")
        t = @to.split("-")
        @dif = (Time.new(t[0],t[1],t[2],0,0,0) - Time.new(f[0],f[1],f[2],0,0,0))/(60*60*24)
        @val = Array.new
        queries = LogZoneQuery.where("queries_date <= ? AND queries_date >= ?", @to, @from).where(:zone_id => @zone.id)

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
            total_queries = 0
            queries.each do |q|
              @a = v
              @b = q.queries_date
              if v.to_s == q.queries_date.to_s
                total_queries = q.queries_count + total_queries
              end
            end
            vv = v.split("-")
            @val[x] = "[Date.UTC(#{vv[0]}, #{(vv[1].to_i-1)}, #{vv[2]}), #{total_queries}],"
        end
      
    else

        if params[:date].blank?
          @date = Time.now.strftime("%Y-%m-%d")
        else
          @date = params[:date]
        end
        gdate = @date.split("-")
        @year = gdate[0]
        @month = gdate[1]
        @day = gdate[2]
        #logs = LogTotalZoneQuery.where(:log_date => @date, :zone_id => @zone.id)
        #JSON.parse HTTParty.get('http://localhost:3000/apis/via_my/one_hour_queries?date=2010-10-03').response.body
        logs = JSON.parse HTTParty.get("http://test.dnscell.com/apis/test_dnscell_com/one_hour_queries?date=2012-02-10&auth_token=yoxHmLzETae9WnzCWiK4").response.body
        #logs.each do |log|
        #end
        log = Hash.new

        0.upto(23).each do |x|
          log["log_#{x+1}_count"] = 0
        end
        
        logs.each do |l|
          #0.upto(23).each do |x|
            0.upto(23).each do |y|
                log["log_#{y+1}_count"] = l["log_#{y+1}_count"] + log["log_#{y+1}_count"]    
            end
          #end
        end

        unless log.empty?
          @x = Array.new
          0.upto(23).each do |x|
            #instance_variable_set("@log_" + (x+1).to_s + "_count", log.log_1_count)
            @x[x] = log["log_#{x+1}_count"]
            #range_start = "#{date} #{x}:00:00"
            #range_end = "#{date} #{x+1}:00:00"
            #@x[x] = LogQuery.where("date_time <= ? AND date_time > ?", range_end, range_start).where(:zone_id => @zone.id).count
            #@x[x] = Query.count(conditions: { "date_time" => {"$lte" => range_end}, date_time: {"$gte" => range_start}, query: /.*#{url2domain(params[:id])}/ })
          end
        else
          respond_to do |format|
            format.html 
            format.js {render :js => "$('#container').html('No data')"}
          end
        end
        
    end
    #respond_to do |format|
    #  format.html
    #  format.js 
    #end
  end

  def graph2
    get_zones_and_zone params[:id]
    @date = "2010-10-03"
    gdate = @date.split("-")
    @year = gdate[0]
    @month = gdate[1]
    @day = gdate[2]
    logs = LogZoneQuery.where(:queries_date => @date, :zone_id => @zone.id)
    unless logs.empty?
      @x = Array.new
      logs.each do |log|
        @x << [log.resource, log.queries_count]
      end
    else
        respond_to do |format|
            format.html 
            format.js {render :js => "$('#container').html('No data')"}
          end
    end

  end

=begin
  def graph2
    get_zones_and_zone params[:id]
    @from = "2011-12-06"
    @to = "2012-01-06"
    f = @from.split("-")
    t = @to.split("-")
    @dif = (Time.new(t[0],t[1],t[2],0,0,0) - Time.new(f[0],f[1],f[2],24,0,0))/(60*60*24)
    @val = Array.new
    queries = LogZoneQuery.where("queries_date <= ? AND queries_date >= ?", @to, @from).where(:zone_id => @zone.id)


    (0..@dif.floor).each do |x|
        v = (Time.new(f[0],f[1],f[2],0,0,0)+x.day).strftime("%Y-%m-%d")
        total_queries = 0
        queries.each do |q|
          @a = v
          @b = q.queries_date
          if v.to_s == q.queries_date.to_s
            total_queries = q.queries_count
          end
        end
        vv = v.split("-")
        @val[x] = "[Date.UTC(#{vv[0]}, #{(vv[1].to_i-1)}, #{vv[2]}), #{total_queries}],"
    end

  end
=end

  def new_scope
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @scope = Share.new
  end

  def create_scope
    @share = Share.new(params[:share])
    @zone = Zone.find(@share.zone_id)
    #@share.host = "#{@share.host}.#{@zone.zone_name}"
    @share.user_id = current_user.id
    if @share.save
      @shares = Share.where(:zone_id => @zone.id)
      @notice = "Scope was created"
      render "create_scope.js"
    else
      #@error = @share.errors.full_messages
      # @error << @zone_tsig.errors.full_messages
      #render 'error.js'
      @errors = []
      @share.errors.each {|x| @errors << @share.errors[x]}
      render 'error.js'
    end
  end

  def destroy_scope
    @share = Share.find(params[:share_id])
    @share.user_id = current_user.id
    @share.destroy
    zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @shares = Share.where(:zone_id => zone.id)
    @notice = 'Scope was successfully deleted!'
    render "destroy_scope.js"
  end

  def new_permission
    @share = Share.find(params[:share_id])
    @user_domain = UserDomain.new
    not_in = Share.find(@share.id).users.map{|u| u.id} + User.where(:role => 0).map{|u| u.id }
    @users = User.where("id not in (?)", not_in).map{|u| [u.username, u.id]}
  end

  def create_permission
    @user_domain = UserDomain.new(params[:user_domain])
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    if @user_domain.save
      @shares = Share.where(:zone_id => @zone.id)
      @notice = "Permission was created"
      render "create_scope.js"
    else
      #@error = @share.errors.full_messages
      # @error << @zone_tsig.errors.full_messages
      #render 'error.js'
      @errors = []
      @user_domain.errors.each {|x| @errors << @user_domain.errors[x]}
      render 'error.js'
    end
  end

  def destroy_permission
    @user_domain = UserDomain.find(params[:permission_id])
    @user_domain.destroy
    zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @shares = Share.where(:zone_id => zone.id)
    @notice = 'Permission was successfully deleted!'
    render "destroy_scope.js"
  end

  def edit_permission
    @user_domain = UserDomain.find(params[:permission_id])
    @share = Share.find(@user_domain.share_id)
  end

  def update_permission
    @user_domain = UserDomain.find(params[:permission_id])
    if @user_domain.update_attributes(params[:user_domain])
      zone = Zone.find_by_zone_name(url2domain(params[:id]))
      @shares = Share.where(:zone_id => zone.id)
      @notice = "Permission was updated"
      render "create_scope.js"
    else
      @errors = []
      @user_domain.errors.each {|x| @errors << @user_domain.errors[x]}
      render 'error.js'    
    end
  end

  def nodes
    get_zones_and_zone params[:id]
  end

  def save_expiry
    @zone = Zone.find_by_zone_name(url2domain(params[:id]))
    @zone.expiry_date = params[:date]
    @zone.save
    render :js => "$('.expiry_date').html('#{params[:date]}')"
  end
end
