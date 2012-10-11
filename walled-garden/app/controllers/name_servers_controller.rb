class NameServersController < ApplicationController
  # GET /name_servers
  # GET /name_servers.json
  def index
    @name_servers = NameServer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @name_servers }
    end
  end

  # GET /name_servers/1
  # GET /name_servers/1.json
  def show
    @name_server = NameServer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @name_server }
    end
  end

  # GET /name_servers/new
  # GET /name_servers/new.json
  def new
    #Ajax after delete
    zone_id = params[:zone_id]
    zone_id = zone_id.to_i unless zone_id.match(/[^[:digit:]]+/)
    if zone_id.is_a?(Integer)
      @zone = Zone.find(params[:zone_id])
    else
      @zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
    end

    @name_server = ZoneNameServer.new
    #@name_server.ns_ttl = Dnscell::Utils.default_ttl
    @name_server.ns_ttl = ZoneNameServer.where(:zone_id => @zone.id, :primary => true).first.ns_ttl
  end

  # GET /name_servers/1/edit
  def edit
    @zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
    @name_server = ZoneNameServer.find(params[:id])
  end

  # POST /name_servers
  # POST /name_servers.json
  def create
      @zone_name_server = ZoneNameServer.new(params[:zone_name_server])
      @zone_name_server.primary = false
      @zone_name_server.zone_id = params[:zone_name_server][:zone_id]
      @zone_name_server.user_id = current_user.id
  
    if @zone_name_server.save
      @primary = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => true)
      @slaves = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => false)
      @zone = Zone.find @zone_name_server.zone_id
      flash[:notice] = 'Name server was successfully created.'
      #redirect_to ns_zone_path, :notice => "Yeay NS was created!"
    else
      #@zone_ns_glue = ZoneNs.new
        #@zone_ns_glue.ns_ttl = @zone_ns.ns_ttl
        #@zone_ns_glue.ns  = @zone_ns.ns
        if @zone_name_server.errors.include?(:glue)
          zone_id = params[:zone_id]
          zone_id = zone_id.to_i unless zone_id.match(/[^[:digit:]]+/)
          if zone_id.is_a?(Integer)
            @zone = Zone.find(params[:zone_id])
          else
            @zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
          end
          @zone_name_server.ipv4_ttl = Dnscell::Utils.default_ttl
          @zone_name_server.ipv6_ttl = Dnscell::Utils.default_ttl
          render 'glue_ns'
        else
          render "error.js"
          #render 'new_ns' 
      end
    end
  end

  def create_ns_glue
      unless params[:zone_name_server].blank?
        @zone_name_server = ZoneNsGlue.new(params[:zone_name_server])
      else
        @zone_name_server = ZoneNsGlue.new(params[:zone_name_server_glue])
      end
      @zone_name_server.primary = false
      @zone_name_server.glue = true
      @zone_name_server.user_id = current_user.id
    if @zone_name_server.save
      @primary = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => true)
      @slaves = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => false)
      @zone = Zone.find @zone_name_server.zone_id
      flash[:notice] = 'Name server was successfully created.'
      render 'create.js'
      #redirect_to ns_zone_path, :notice => "Yeay NS was created!"
    else
      render "error.js"
    end
  end

  # PUT /name_servers/1
  # PUT /name_servers/1.json
  def update
      @zone_name_server = ZoneNameServer.find(params[:id])
      @zone_name_server.ns = params[:zone_name_server][:ns]
      @zone_name_server.ns_ttl = params[:zone_name_server][:ns_ttl]
      @zone_name_server.update_ns_host = params[:zone_name_server][:update_ns_host]
      @zone_name_server.user_id = current_user.id
      @zone_name_server.glue = false
      #@zone_ns.update_attributes(params[:zone_ns])
      #if @zone_name_server.changed?
        if @zone_name_server.save
          @primary = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => true)
          @slaves = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => false)
          @zone = Zone.find @zone_name_server.zone_id
          flash[:notice] = 'NS was successfully updated.'
          #redirect_to ns_zone_path(@zone_ns.zone_id), notice: 'NS was successfully updated.' 
          render 'update.js'
        else
          if @zone_name_server.errors.include?(:glue)
            zone_id = params[:zone_id]
            zone_id = zone_id.to_i unless zone_id.match(/[^[:digit:]]+/)
          if zone_id.is_a?(Integer)
            @zone = Zone.find(params[:zone_id])
          else
            @zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
          end
            #@zone_name_server.ipv4_ttl = Dnscell::Utils.default_ttl
            #@zone_name_server.ipv6_ttl = Dnscell::Utils.default_ttl
            render 'glue_ns'
          else
            render "error.js"
          #render 'new_ns' 
          end
          #render "glue_ns.js"
        end
      #else
       # @primary = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => true)
       # @slaves = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => false)
       # flash[:notice] = 'No changes found'
        #redirect_to ns_zone_path(@zone_ns.zone_id), notice: 'No changes found' 
        #render action: "edit_ns_glue"
        #render 'create.js'
      #end
  end

  def update_ns_glue
      @zone_name_server = ZoneNsGlue.find(params[:id])
      @zone_name_server.glue = true
      @zone_name_server.user_id = current_user.id
      if @zone_name_server.update_attributes(params[:zone_name_server])
        @primary = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => true)
        @slaves = ZoneNameServer.where(:zone_id => @zone_name_server.zone_id, :primary => false)
        @zone = Zone.find @zone_name_server.zone_id
        flash[:notice] = 'NS was successfully updated.'
        #redirect_to ns_zone_path(@zone_name_server.zone_id), notice: 'NS was successfully updated.' 
        render 'update.js'
      else
        render "error.js"
      end
  end
  # DELETE /name_servers/1
  # DELETE /name_servers/1.json
  def destroy
    @name_server = ZoneNameServer.find(params[:id])
    #@zone = Zone.find(@name_server.zone_id)
    @name_server.user_id = current_user.id
    @name_server.destroy

    @primary = ZoneNameServer.where(:zone_id => @name_server.zone_id, :primary => true)
    @slaves = ZoneNameServer.where(:zone_id => @name_server.zone_id, :primary => false)
    @zone = Zone.find @name_server.zone_id
    #@zone = Zone.find_by_zone_name(url2domain(params[:zone_id]))
    #@name_servers = @zone.name_servers
    flash[:notice] = 'Name server was successfully deleted.' 
  end
end
