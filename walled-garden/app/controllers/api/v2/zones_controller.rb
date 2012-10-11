class Api::V2::ZonesController < API::V2::ApplicationController
  def index
	  	if params[:limit].blank?
	  		params[:limit]  = 100
	  	else
	  		limit_int  = Integer(params[:limit]) rescue false 
	    end

	    if params[:offset].blank?
	  		params[:offset] = 0
	  	else
	  		offset_int = Integer(params[:offset]) rescue false
	  	end

	  	if limit_int == false || offset_int == false
	  		render :json => {:error => "Bad Request Exception: offset & limit must in integer"}
	  	#elsif params[:limit] < params[:offset]
	  	else
	  		zones = Zone.limit(Integer(params[:limit])).offset(Integer(params[:offset]))
	  		ActiveRecord::Base.include_root_in_json = false
	  		z = {"zones" =>  JSON.parse(zones.to_json(:only => [ :id, :zone_name ])) } 
	  		render :json => z.to_json
	  	#else
	  	#	render :json => {:error => "Bad Request Exception: ! offset < limit"}
	  	end
  end

  def total_zone 
  	#return total zones
  	count = Zone.count
  	render :json => {:total => count}
  end

  def total_host
  	c = Zone.where(:id => params[:id]).first
  	if c.nil?
  		render :json => {:info => "Not found"}
  	else
  		count = c.hosts.count
  		render :json => {:total => count}
  	end
  end

  def hosts
  	if params[:limit].blank?
	  		params[:limit]  = 100
  	else
  		limit_int  = Integer(params[:limit]) rescue false 
    end

    if params[:offset].blank?
  		params[:offset] = 0
  	else
  		offset_int = Integer(params[:offset]) rescue false
  	end

  	if limit_int == false || offset_int == false
  		render :json => {:error => "Bad Request Exception: offset & limit must in integer"}
  	#elsif params[:limit] < params[:offset]
  	else
	  	z = Zone.where(:id => params[:id]).first
	  	if z.nil?
	  		render :json => {:info => "Not found"}
	  	else
	  		h = z.hosts.limit(Integer(params[:limit])).offset(Integer(params[:offset]))
	  		ActiveRecord::Base.include_root_in_json = false
	  		z = {"hosts" =>  JSON.parse(h.to_json(:only => [ :id, :combine ])) } 
		  	render :json => z.to_json
	  	end
	end
  end

  def hosts_with_records
  	if params[:limit].blank?
	  		params[:limit]  = 100
  	else
  		limit_int  = Integer(params[:limit]) rescue false 
    end

    if params[:offset].blank?
  		params[:offset] = 0
  	else
  		offset_int = Integer(params[:offset]) rescue false
  	end

  	if limit_int == false || offset_int == false
  		render :json => {:error => "Bad Request Exception: offset & limit must in integer"}
  	#elsif params[:limit] < params[:offset]
  	else
	  	z = Zone.where(:id => params[:id]).first
	  	if z.nil?
	  		render :json => {:info => "Not found"}
	  	else
	  		h = z.hosts.limit(Integer(params[:limit])).offset(Integer(params[:offset]))
	  		ActiveRecord::Base.include_root_in_json = false
	  		z = {"hosts" =>  JSON.parse(h.to_json(:only => [ :id, :combine ], :include => {:records => {
                                               :only => [:rr_host, :rr_type, :data] }} )) } 
		  	render :json => z.to_json
	  	end
	end
  end


end