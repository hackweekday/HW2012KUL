module Admin
	class DomainsController < BaseController
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
	end
end