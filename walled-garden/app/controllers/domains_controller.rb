class DomainsController < ApplicationController
	# GET /domains
  # GET /domains.json
  # http_basic_authenticate_with :name => "admin", :password => "localhost2012"
  #before_filter :authenticate_user!
  
  layout 'login'
  
  set_tab :main

  def index
    @label = "All"
    @domains = Domain.where(:status => true).search(params[:search]).paginate(:per_page => 10, :page => params[:page])

    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.json { render json: @domains }
    #end
    #send_data '', :filename => 'ipv4.png', :type => 'image/png', :disposition => 'inline'
    #send_file 'app/assets/images/ipv4.png', :type => 'image/png', :disposition => 'inline'
  end

  def ready
    @label = "Ready"
    @domains = Domain.where(:status => true, :v6_status => 2).search(params[:search]).paginate(:per_page => 10, :page => params[:page])
    respond_to do |format|
      format.html { render 'index.html' }# index.html.erb
      format.js { render 'index.js' }
    end
  end

  def not_ready
    @label = "Not Ready"
    @domains = Domain.where(:status => true, :v6_status => 0).search(params[:search]).paginate(:per_page => 10, :page => params[:page])
    respond_to do |format|
      format.html { render 'index.html' }# index.html.erb
      format.js { render 'index.js' }
    end
  end

  def incomplete
    @label = "Incomplete"
    @domains = Domain.where(:status => true, :v6_status => 1).search(params[:search]).paginate(:per_page => 10, :page => params[:page])
    respond_to do |format|
      format.html { render 'index.html' }# index.html.erb
      format.js { render 'index.js' }
    end
  end

  # GET /domains/1
  # GET /domains/1.json
  def show
    @domain = Domain.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @domain }
    end
  end

  # GET /domains/new
  # GET /domains/new.json
  def new
    @domain = Domain.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @domain }
    end
  end

  # GET /domains/1/edit
  def edit
    @domain = Domain.find(params[:id])
  end

  # POST /domains
  # POST /domains.json
  def create
    @domain = Domain.new(params[:domain])

    respond_to do |format|
      if @domain.save
        format.html { redirect_to @domain, notice: 'domain was successfully created.' }
        format.json { render json: @domain, status: :created, location: @domain }
      else
        format.html { render action: "new" }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /domains/1
  # PUT /domains/1.json
  def update
    @domain = Domain.find(params[:id])

    respond_to do |format|
      if @domain.update_attributes(params[:domain])
        format.html { redirect_to @domain, notice: 'domain was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domains/1
  # DELETE /domains/1.json
  def destroy
    @domain = Domain.find(params[:id])
    @domain.destroy

    respond_to do |format|
      format.html { redirect_to domains_url }
      format.json { head :no_content }
    end
  end
end
