class UsersController < ApplicationController
  set_tab :appliance_management
  set_tab :message, :first_level, :only => %w(messages)
  set_tab :notification, :first_level, :only => %w(records_requests)
  skip_filter :only_admin, :only => %w(sign_out messages get_paginated_messages delete_message edit_password update_password records_requests get_paginated_records_requests)

  #before_filter :auth_user, :except => [:new, :create]

  before_filter :authenticate_user! , :except => [:new, :create, :sign_out]
  def dashboard
    zone_list
    respond_to do |f|
      f.js { render 'zone_list.js' }
      f.html {}
    end

    @top5_host = []
    @top5_host.push(Dnscell::Utils.top_host Date.new(DateTime.now.year, DateTime.now.month, 1).to_s, Date.new(DateTime.now.year, DateTime.now.month, -1).to_s) 
    @top5_host.push(Dnscell::Utils.top_host (DateTime.now - 7).strftime("%Y-%m-%d"), DateTime.now.strftime("%Y-%m-%d")) 
    @top5_host.push(Dnscell::Utils.top_host)

    @top5_zone = []
    @top5_zone.push(Dnscell::Utils.top_zone Date.new(DateTime.now.year, DateTime.now.month, 1).to_s, Date.new(DateTime.now.year, DateTime.now.month, -1).to_s) 
    @top5_zone.push(Dnscell::Utils.top_zone (DateTime.now - 7).strftime("%Y-%m-%d"), DateTime.now.strftime("%Y-%m-%d")) 
    @top5_zone.push(Dnscell::Utils.top_zone)
    @hw_id, @organization, @support_expiry_date, @license_expiry_date, @serial_number = Dnscell::Utils.device_info
  end

  def zone_list
    @zones = Zone.paginate(:page => params[:page].nil? ? 1 : params[:page], :per_page => 5)
  end

  def get_paginated_records_requests    
    case params[:iSortCol_0]
    when "0"
      sort_variable = "created_at desc"
    when "3"
      sort_variable = "created_at #{params[:sSortDir_0]}"
    end
      # display_msg_type = [["inbox","receiver_id"],["outbox","sender_id"]].find_all{|x| x[0] == params[:display_msg_type]}[0][1]
      status_types = [["Pending",0],["Approved",1],["Rejected",2]]
      status_type = status_types.find_all{|x| x[0] == params[:display_type]}[0][1]
      # if params[:display_type] == "0"
        @records_requests = RecordsRequest.where(" approved_status = #{status_type} ").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      # else
      #   @records_requests = current_user.sent_messages.where("msg like ?", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      # end
      @pending_count = RecordsRequest.where(" approved_status = 0 ").length
      @approved_count = RecordsRequest.where(" approved_status = 1 ").length
      @rejected_count = RecordsRequest.where(" approved_status = 2 ").length

      @count = @records_requests.count
  end

  def records_requests
  end


  def get_paginated_messages
    case params[:iSortCol_0]
    when "0"
      sort_variable = "created_at desc"
    when "3"
      sort_variable = "created_at #{params[:sSortDir_0]}"
    end
      display_msg_type = [["inbox","receiver_id"],["outbox","sender_id"]].find_all{|x| x[0] == params[:display_msg_type]}[0][1]
      if params[:display_msg_type] == "inbox"
        @messages = current_user.received_messages.where("msg like ?", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      else
        @messages = current_user.sent_messages.where("msg like ?", "%#{params[:sSearch]}%").order("#{sort_variable}").paginate(:page => (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i)+1, :per_page => params[:iDisplayLength])
      end
      @inbox_count = current_user.received_messages.length
      @outbox_count = current_user.sent_messages.length
      @messages_count = @messages.count
  end

  def messages
  end

  def new_message
  end

  def delete_message
    params[:msg_ids].split(",").each do |m|
      message = Message.find(m)
      logger.debug "debug #{params[:display_type]}"
      if params[:display_type] == "inbox"
        message.update_attributes(:receiver_delete => true)
        logger.debug "delete atas"
      else
        message.update_attributes(:sender_delete => true)
      logger.debug "delete bawah"

      end
    end
    render :js => "$('#dttb_message').dataTable().fnDraw(false);"
  end

  # GET /users
  # GET /users.json
  #layout nil
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
#    if (current_user.id == @user.id)
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user }
      end
#    else
#      render :text => "You are not allowed"
#    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
      format.js {} #~~ 
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    if (current_user.id != @user.id)
      #render :text => "You are not allowed"
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  def welcome

  end

  def edit_password
    @user = User.find current_user.id
    respond_to :html, :js  
  end

  def update_password
     @user = User.find current_user.id
     #user = login(@user.username, params[:user][:current_password], remember_me = false)
     user = @user.valid_password?(params[:user][:current_password])
     if user
      if @user.update_attributes(params[:user])
      sign_out :user
      @notice = "Password was successful updated"
      flash[:notice] = "Password was successful updated"
      render "create_password.js"
      #redirect_to new_user_session_path
      #render :js => "window.location = '#{new_user_session_path}'";
      else
        @errors = []
        unless user
          @errors << "Invalid current password!"
        end
        @user.errors.each {|x| @errors << @user.errors[x]}
        render 'error.js'
      end
    else
      @errors = []
      unless user
        @errors << "Invalid current password!"
      end
      @user.errors.each {|x| @errors << @user.errors[x]}
      render 'error.js'
    end
  end
end