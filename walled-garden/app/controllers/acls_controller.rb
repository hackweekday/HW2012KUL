class AclsController < ApplicationController
	set_tab :acl, :first_level

	def index
        if AclName.first
            redirect_to acl_path(AclName.first)
        else

        end

	end

	def show
        @acl_names = AclName.all
		@acl_name = AclName.find(params[:id])
		@address_match_lists = @acl_name.address_match_lists.order(:position)
		@address_match_list = AddressMatchList.new
	end
    
    def new
        @acl_name = AclName.new
    end

    def create
    	@acl_name = AclName.new(params[:acl_name])
    	if @acl_name.save
           update_acl
           @notice = "New ACL has been created"
           @acl_names = AclName.all
           render :js => "window.location = '#{acl_path(@acl_name)}'"
    	else
    	   @error = @acl_name.errors.full_messages
            render 'error.js'
           # render 'acls/index'
    	end
    end

    def create_address_match_list
    	@address_match_list = AddressMatchList.new(params[:address_match_list])
    	@address_match_list.acl_name_id = params[:id]
    	if @address_match_list.save
    	   update_acl
           acl_ls
           @notice = "Address created for this ACL"
    	   # redirect_to acl_path(params[:id])
    	else
            # acl_ls
            @error = @address_match_list.errors.full_messages
            render 'error.js'
    	end
    
	end

	def destroy_address_match_list
		@address_match_list = AddressMatchList.find(params[:data_id])
    	@address_match_list.destroy
    	update_acl
        acl_ls
        @notice = "Address deleted for this ACL"
        render "create_address_match_list.js"
	end

	def destroy
		@acl_names = AclName.find(params[:id])
    	@acl_names.destroy
    	update_acl
    	redirect_to acls_path
	end

	def sort
		params[:address_match_list].each_with_index do |id, index|
			AddressMatchList.update_all(['position=?', index+1], ['id=?', id])
		end
		#render :nothing => true
		update_acl
		render :js => "$('#flash').html('ACL has been rearranged');$('#flash').slideDown(300).delay(800).fadeIn(400).delay(3000).fadeOut(400);"
	end

	def update_acl
	    Resque.enqueue(UpdateAclApplication)
    end

    def acl_ls
        @acl_names = AclName.all
        @acl_name = AclName.find(params[:id])
        @address_match_lists = @acl_name.address_match_lists.order(:position)
        @address_match_list = AddressMatchList.new
    end
end
