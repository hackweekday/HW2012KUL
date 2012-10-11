class API::ApplicationController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  respond_to :json

  def parse_body_json
    @attributes = JSON.parse(request.body.read)
  end

  def parse_body_non_json
    process = request.body.read.split("=")
    @attributes = JSON.parse(process[1])
    #process2 = process[1].split(">")
    #if process2.count == 1
    #   @attributes = JSON.parse(process2[0])  
    #else
    #   #process2[1].slice!(0)
  	#   #@attributes = JSON.parse(process2[1].chop.chop.gsub("'","\""))
    #   @attributes = JSON.parse(process2[1].chop.to_json)
    #end
  	#Rails.logger.auto_flushing = true
    #Rails.logger.info "makan #{process} at #{Time.now}.\n"
  end

  def record_not_found
    head :not_found
  end

  def validate_request
    #Check if okay or not, remote_id - send remote_id
    #params[:remote_id] = id on local
    check = NodeCheck.new(:ip_address => "192.168.0.111", 
                          :node_serial => "adad", 
                          :auth_token => "adasd")
  end

  def get_ip
    #need to check
    if request.remote_ip == "127.0.0.1"
      remote_ip = request.env["HTTP_X_FORWARDED_FOR"] 
    else
      remote_ip = request.remote_ip
    end
    return remote_ip
  end
end