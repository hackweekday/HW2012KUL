class TsigsController < ApplicationController
  layout 'application_without_sidebar'
  set_tab :zone_management

  set_tab :keys, :first_level
  def index
    #@tsigs = Tsig.order("created_at").where(:server_id => 0)
    @tsigs = Tsig.order("created_at")
  end

  def new
    @tsig = Tsig.new
    @from = params[:from]
  end

  def edit
    @tsig = Tsig.find(params[:id])
    render 'new.js'
  end

  def update
    @tsig = Tsig.find(params[:id])
    if @tsig.update_attributes(params[:tsig])
      @notice = "Tsig updated!"
      Resque.enqueue(TsigsServersApplication)
      @tsigs = Tsig.order("created_at")
      render 'create.js'
    else
      @error = @tsig.errors.full_messages
      render 'error.js'
    end
  end

  def create
    @tsig = Tsig.new(params[:tsig])
    if @tsig.save
      @tsigs = Tsig.order("created_at")
      Resque.enqueue(TsigsServersApplication)
      @notice = "Successfully create tsig"
    else
      @error = @tsig.errors.full_messages
      render 'error.js'
    end
  end

  def destroy
    @tsig = Tsig.find(params[:id])
    if @tsig.destroy
      @tsigs = Tsig.order("created_at")
      Resque.enqueue(TsigsServersApplication)
      @notice = "Successfully delete tsig"
    else

    end

  end

  def keygen
    @keyword = params[:tsig][:keyword].downcase
    @secret = Dnscell::Tsigkey.generate_tsig "#{@keyword}", "#{params[:tsig][:algorithm]}", params[:tsig][:algorithm_size].to_i
    # render :js => "alert(#{params[:key]})"
  end

  def tsig_popup
    @tsigs = Tsig.order("created_at")
    render :layout => 'none'
  end
end
