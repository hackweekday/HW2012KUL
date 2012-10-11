class ApisController < ApplicationController
	respond_to :json
	#layout :false
  skip_filter :require_login, :only_admin, :set_timezone
  #, :only_admin, :set_timezone
 
  def index
    @zones = Zone.all
    respond_with(@zones)
  end
  
  def get_ip
  	#render :text => request.remote_ip
    if request.remote_ip == "127.0.0.1"
      remote_ip = request.env["HTTP_X_FORWARDED_FOR"] 
    else
      remote_ip = request.remote_ip
    end
  	render :text => remote_ip
  end

  def show
  	zones = Zone.select("zone_name, allow_query").all
  	ActiveRecord::Base.include_root_in_json = false
    z = {"zones" =>  zones} 
    render :json => z.to_json()
    #render :text => '{"zones": [ {"id":190,"zone_name":"amir.com"},{"id":196,"zone_name":"bn"},{"id":198,"zone_name":"hackers.com"},{"id":199,"zone_name":"aist.my"}]}'
  end

  def register_appliance
    @appliance = Appliance.new(params[:appliance])
    respond_to do |format|
      if @appliance.save
        format.json { render json: @appliance, status: :created, location: @appliance }
      else
        format.json { render json: @appliance.errors, status: :unprocessable_entity }
      end
    end
  end

  def one_hour_queries
    zone = Zone.find_by_zone_name(url2domain(params[:id]))
    date = params[:date]
    data = LogTotalZoneQuery.where(:log_date => date, :zone_id => zone.id)
    #z = {"data" =>  data}
    render :json => data.to_json()
  end

  def show_json
  end

  def create
  	#Create the data thru json, where it will be great
	end

  def graph
    @date = params[:date]
    @x = Array.new
    0.upto(23).each do |x|
      range_start = "#{@date} #{x}:00:00"
      range_end = "#{@date} #{x+1}:00:00"
      #@x[x] = Query.where("date_time <= ? AND date_time >= ?", range_end, range_start).count
      @x[x] = Query.count(conditions: { "date_time" => {"$lte" => range_end}, date_time: {"$gte" => range_start} })
    end
  end

  def g2
    @date = params[:date]
    gdate = params[:date].split("-")
    @year = gdate[0]
    @month = gdate[1]
    @day = gdate[2]
  
    @x = Array.new
    @a = Array.new
    @ptr = Array.new
    0.upto(23).each do |x|
      range_start = "#{@date} #{x}:00:00"
      range_end = "#{@date} #{x+1}:00:00"
      #@x[x] = Query.where("date_time <= ? AND date_time >= ?", range_end, range_start).count
      @x[x] = Query.count(conditions: { "date_time" => {"$lte" => range_end}, date_time: {"$gte" => range_start} })
      @a[x] = Query.count(conditions: { "date_time" => {"$lte" => range_end}, date_time: {"$gte" => range_start}, resource: "A" })
      @ptr[x] = Query.count(conditions: { "date_time" => {"$lte" => range_end}, date_time: {"$gte" => range_start}, resource: "PTR" })
    end
    #@x.shift

  end

  def i18n
   @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      f.series(:name=>'John', :data=>[3, 20, 3, 5, 4, 10, 12 ,3, 5,6,7,7,80,9,9])
      f.series(:name=>'Jane', :data=> [1, 3, 4, 3, 3, 5, 4,-46,7,8,8,9,9,0,0,9] )
    end
    render :layout => "none"  
  end

  def report
        
        @zone = Zone.find_by_zone_name("via.my")
        @date = params[:date]
        gdate = params[:date].split("-")
        @year = gdate[0]
        @month = gdate[1]
        @day = gdate[2]
        @logs = LogTotalZoneQuery.where(:log_date => @date, :zone_id => @zone.id)
        log = Hash.new

        0.upto(23).each do |x|
          log["log_#{x+1}_count"] = 0
        end
        
        @logs.each do |l|
          #0.upto(23).each do |x|
            0.upto(23).each do |y|
                log["log_#{y+1}_count"] = l["log_#{y+1}_count"] + log["log_#{y+1}_count"]    
            end
          #end
        end

        unless log.empty?
          @x = Array.new
          0.upto(23).each do |x|
            @x[x] = log["log_#{x+1}_count"]
          end
        else
          respond_to do |format|
            format.html 
            format.js {render :js => "$('#container').html('No data')"}
          end
        end
        render :layout => 'none'
  end

end
