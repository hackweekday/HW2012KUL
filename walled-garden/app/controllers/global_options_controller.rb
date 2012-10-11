class GlobalOptionsController < ApplicationController
  set_tab :zone_management
  set_tab :global_options, :first_level
  def index
    redirect_to soa_global_options_path
  end

  def soa
    set_tab :soa, :global_options
    if Soa.count > 0
      @soa = Soa.first
    else
      @soa = Soa.new
    end
    render 'index'
  end

  def soa_save
    if params[:go_soa][:id].present?
      @soa = Soa.find(params[:go_soa][:id])
      if @soa.update_attributes(params[:go_soa])
        flash[:notice] = "Global Option - SOA record has been saved"
        # render 'zones/soa_create.js'
        redirect_to soa_global_options_path
      else
        render 'zones/soa_error.js'
      #render :js => "alert('cant update_attributes')" #error
      end
    else
      @soa = Soa.new(params[:go_soa])
      if @soa.save
        flash[:notice] = "Global Option - SOA record has been created"
        render 'zones/soa_create.js'
      else
        render 'zones/soa_error.js'
      #render :js => "alert('cant create')" #error
      end
    end #0173621301
  end

  def name_servers
    @primaries = NameServer.where(:go => 1,:p_or_s => 0)
    @secondaries = NameServer.where(:go => 1,:p_or_s => 1)
    if params[:go] == "1"
      render 'global_options/name_servers/create.js'
    else
      set_tab :name_servers, :global_options
      render 'index'
    end

  end

  def new_name_server
    @name_server = NameServer.new
    render 'global_options/name_servers/new.js'
  end

  def del_name_server
    @name_server = NameServer.find(params[:del])
    @name_server.destroy
    flash[:notice] = "Global Option - Name Server has been deleted"
    @primaries = NameServer.where(:go => 1,:p_or_s => 0)
    @secondaries = NameServer.where(:go => 1,:p_or_s => 1)
    render 'global_options/name_servers/create.js'
  end

  def edit_name_server
    @name_server = NameServer.find(params[:id])
    render 'global_options/name_servers/edit.js'
  end

  def create_name_server
    @name_server = NameServer.new(params[:name_server])
    @name_server.p_or_s = "1" if params[:name_server][:p_or_s] != "0"
    if @name_server.save
      # format.html { redirect_to @name_server, notice: 'Name server was successfully created.' }
      flash[:notice] = 'Name server was successfully created.'
      if @name_server.go == "1"
        @primaries = NameServer.where(:go => 1,:p_or_s => 0)
        @secondaries = NameServer.where(:go => 1,:p_or_s => 1)
        redirect_to name_servers_global_options_path(:go => '1')
      else

        @zone = Zone.find(params[:name_server][:zone_id])
        @primaries = @zone.name_servers.where(:p_or_s => 0)
        @secondaries = @zone.name_servers.where(:p_or_s => 1)
        @name_servers = @zone.name_servers
      end
    else
      render "name_servers/error.js"
    end
  end

  def update_name_server
    @name_server = NameServer.find(params[:name_server][:id])

    respond_to do |format|
      if @name_server.update_attributes(params[:name_server])
        @primaries = NameServer.where(:go => 1,:p_or_s => 0)
        @secondaries = NameServer.where(:go => 1,:p_or_s => 1)
        flash[:notice] = 'Name server was successfully updated.'
        format.js { render "global_options/name_servers/create.js" }
        format.html { redirect_to @name_server, notice: 'Name server was successfully updated.' }
        format.json { head :ok }
      else
        format.js { render "name_servers/error.js" }
        format.html { render action: "edit" }
        format.json { render json: @name_server.errors, status: :unprocessable_entity }
      end
    end
  end

end