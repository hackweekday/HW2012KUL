class StatusController < ApplicationController
  set_tab :appliance_management
  set_tab :system, :first_level, :only => %w(index)
  set_tab :cpu, :first_level, :only => %w(cpu)
  set_tab :ram, :first_level, :only => %w(ram)
	def index
		@status = Hash.new
		#%x{god status}.each_line do |x| 
   	#		alter = x.chomp.split(":")
   	#		if alter.count == 2
    # 			status = alter[1] 
    # 			status.strip =="up" ? @status[alter[0]] = "up" : @status[alter[0]] = "down" 
   	#		end
   	#	end
    @uptime = "Up #{Sys::Uptime.dhms[0]} days, #{Sys::Uptime.dhms[1]} hours and #{Sys::Uptime.dhms[2]} minutes"

  #   if Dnscell::Status.port(53)
  #     @status["DNS Daemon"] = true #
  #   else
  #     @status["DNS Daemon"] = false
  #   end

  #   if Dnscell::Status.port(6379)
  #     @status["Redis Daemon"] = true
  #   else
  #     @status["Redis Daemon"] = false
  #   end

  #   if Dnscell::Status.dnscell_worker
  #     @status["DNSCELL worker"] = true
  #   else
  #     @status["DNSCELL worker"] = false
  #   end

  #   if Dnscell::Status.port(6379)
  #     @status["Resque Daemon"] = true
  #   else
  #     @status["Resque Daemon"] = false
  #   end

  #   if Dnscell::Status.daemon("logs_worker")
  #     @status["Log worker - Queries"] = true
  #   else
  #     @status["Log worker - Queries"] = false
  #   end

  #   if Dnscell::Status.daemon("logs_named_worker")
  #     @status["Log worker - named"] = true
  #   else
  #     @status["Log worker - named"] = false
  #   end

  #   if Dnscell::Status.daemon("slave_daemon")
  #     @status["Slave worker"] = true
  #   else
  #     @status["Slave worker"] = false
  #   end

  #   if Dnscell::Status.port(4949)
  #     @status["Munin Daemon"] = true
  #   else
  #     @status["Munin Daemon"] = false
  #   end
    @item_array = ["DNS Daemon", "Redis Daemon", "DNSCELL worker", "Resque Daemon", "Log worker - Queries", "Log worker - named", "Slave worker"]

	end

  def get_status
    case params[:type]
    when 'DNS Daemon'
      status = Dnscell::Status.port(53) == true ? "ok" : "ko"
    when 'Redis Daemon'
      status = Dnscell::Status.port(6379) == true ? "ok" : "ko"
    when 'DNSCELL worker'
      status = Dnscell::Status.dnscell_worker == true ? "ok" : "ko"
    when 'Resque Daemon'
      status = Dnscell::Status.port(6379) == true ? "ok" : "ko"
    when 'Log worker - Queries'
      status = Dnscell::Status.daemon("logs_worker") == true ? "ok" : "ko"
    when 'Log worker - named'
      status = Dnscell::Status.daemon("logs_named_worker") == true ? "ok" : "ko"
    when 'Slave worker'
      status = Dnscell::Status.daemon("slave_daemon") == true ? "ok" : "ko"
    when 'Munin Daemon'
      status = Dnscell::Status.port(4949) == true ? "ok" : "ko"
    else
      status = "unkown"
    end
    render :json => {:status => status}
  end
end