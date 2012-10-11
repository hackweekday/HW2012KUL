class RecursiveOptionsController < ApplicationController
	set_tab :option, :first_level, :only => %w(index)
  def forward 
    data = Option.find_by_statement("forward")
    data.statement_value = params[:forward]
    data.save
    @options = Option.all
    @ip = OptionIp.new
    @f_ips = OptionIp.where(:typ => "forwarders")
    render 'forward_form', :locals => {:type => 'forwarders'}, :layout => false
  end

  def index
		@options = Option.all
    ar_method = get_option("allow-recursion")
    bh_method = get_option("blackhole")
    if ar_method == "1"
      @ar_partial = "zones/zone_opt/ip_ls"
    else
      @ar_partial = "zones/zone_opt/acl_ls"
    end
    if bh_method == "1"
      @bh_partial = "zones/zone_opt/ip_ls"
    else
      @bh_partial = "zones/zone_opt/acl_ls"
    end
    recursive_data_query ar_method, "allow-recursion"
    recursive_data_query bh_method, "blackhole"
    recursive_data_query "1", "forwarders" #get ip list for forwarders
  end

  def edit
    @options = Option.all
     case params[:type]
     when "forwarders"
      render :js => "alert('aa')"
     end

    render :layout => false
  end

  def data_ls
    @type = params[:t]
    case params[:m]
    when "1"
      # @recursive_ips = OptionIp.where(:typ => params[:m])
    when "3"
      @recursive_ips = OptionIp.where(:typ => params[:m])
    end
    unless params[:t] == "ipv4" || params[:t] == "ipv6"
      m = Option.find_by_statement(params[:t])
      m.statement_value = params[:m]
      m.save
    end
    recursive_data_query params[:m], params[:t]
    # @ip = OptionIp.new
    # render :js => 'zones/zone_opt/ip', :locals => {:type => params[:t], :opt_create_zone_path => recursive_options_path}, :layout => false
  end

  def delete 
    @type = params[:t]
    case params[:m]
    when "1"
      n = "Address"
      data = OptionIp.find(params[:i])
    when "3"
      n = "ACL"
      data = RecursiveAcl.find(params[:i])
    end
    data.destroy
    @notice = "#{n} has been deleted"
    recursive_data_query params[:m], params[:t]
    render 'data_ls.js'
  end

  def sort
    @type = params[:t].gsub(/_/,"-")
    case params[:m]
    when '1'
      @partial = "zones/zone_opt/ip"
      params[:ip_list].each_with_index do |id, index|
          OptionIp.update_all(['position=?',index+1], ['id=?', id])
      end
      recursive_data_query params[:m], @type
    when '2'
    when '3'
      params[:acl_list].each_with_index do |id, index|
        RecursiveAcl.update_all(['position=?',index+1], ['id=?', id])
      end
      @partial = "zones/zone_opt/acl"
      recursive_data_query params[:m], @type
      # render :js => "alert('#{params[:m]} #{@type}')"
    end
     render 'data_ls.js'
  end

  def save_data
    @type = params[:t]
    unless params[:option_ip].nil?
      data = OptionIp.new(params[:option_ip])
    else
      data = RecursiveAcl.new(params[:recursive_acl])
      data.method = params[:t]
    end
    if data.save
      recursive_data_query params[:m], params[:t]
      # render :js => "alert('#{params[:m]} #{params[:t]}')"
      render 'data_ls.js'
      @notice = "Successfully added!"
    else
      @error = data.errors.full_messages
      render 'error.js'
        # render :js => "alert('nono')"
    end
  end

  def save
    value = params[:option][:statement] unless params[:option].nil?
    case params[:type]
    # when "recursive-clients"
    when "forwarders", "forward"
      if value.nil?
        value = 0
      else 
        value = 1
      end 
    when "auth-nxdomain"
      if value.nil?
        value = 'no'
      else 
        value = 'yes'
      end
    end
    @type = params[:type]
    data = Option.find_by_statement(params[:type])
    data.update_attributes :statement_value => value
    if data.save 
      @options = Option.all
      @notice = "#{@type} successfully saved!"
      render 'recursive_save.js'
    else
      @error = data.errors.full_messages
      render 'error.js'
    end
  end


  def chk_recursive
  	@chk_recursive = Option.find_by_statement("recursion")
  	@chk_recursive.statement_value = params[:chk_recursive].gsub(/true|false|/, 'true' => 'yes', 'false' => 'no')
  	@chk_recursive.save
  	render :js => "window.location = '#{recursive_options_path}'"
  end

  def recursive_data_query m, t
    @options = Option.all
    case m
    when "1"
      case t
      when "allow-recursion"
        @ar_ips = OptionIp.where(:typ => t).order("position")
      when "blackhole"
        @bh_ips = OptionIp.where(:typ => t).order("position")
      when 'forwarders'
        @f_ips = OptionIp.where(:typ => t).order("position")
      when "ipv4"
        @ipv4_ips = OptionIp.where(:typ => t).order("position")
      when "ipv6"
        @ipv6_ips = OptionIp.where(:typ => t).order("position")
      end
      @ip = OptionIp.new
    when "3"
      case t
      when "allow-recursion"
        @ar_acls = RecursiveAcl.where(:method => t).order("position")
      when "blackhole"
        @bh_acls = RecursiveAcl.where(:method => t).order("position")
        # render :js => "alert('hehe')"
      end
      @acl_names = AclName.all
      @acl = RecursiveAcl.new
    end
  end
end
