class GeneralSettings::EmailsController < ApplicationController
	set_tab :appliance_management

  def index
  	@groups = EmailGroupName.all
		@emails = Email.order("created_at desc")
  end

  # GET /recipients/1
  # GET /recipients/1.json
  def show
    @email = Email.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email }
    end
  end

  # GET /recipients/new
  # GET /recipients/new.json
  def new
    @email = Email.new
  end

  # GET /recipients/1/edit
  def edit
    @email = Email.find(params[:id])
    @groups = @email.email_group_names
    render 'new.js'
  end

  # POST /recipients
  # POST /recipients.json
  def create
    @email = Email.new(params[:email])
      if @email.save
        all_recipient
      else
        render :js => "show_error(eval(#{@email.errors.full_messages}))"
      end
  end

  # PUT /recipients/1
  # PUT /recipients/1.json
  def update
    @email = Email.find(params[:id])

    respond_to do |format|
      if @email.update_attributes(params[:email])
      	@emails = Email.all
        format.html { redirect_to @email, notice: 'Email was successfully updated.' }
        format.json { render json: @email }
        format.js { render 'create.js' }
      else
        format.html { render action: "edit" }
        format.json { render json: @email.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipients/1
  # DELETE /recipients/1.json
  def destroy
    @email = Email.find(params[:id])
    @email.destroy
    all_recipient
    render 'create.js'
  end

  def all_recipient
    @emails = Email.order("created_at desc")
  end

  def all_group
		@groups = EmailGroupName.all
  end

  def delete_email_group
  	gn = EmailGroupName.find(params[:group])
  	g = EmailGroup.find_by_email_id_and_email_group_name_id(params[:id],params[:group]).destroy
  	render :js => "
  	$('#form_EmailGroupName#{params[:group]}').remove()
  	$('#group_select').append('<option value=#{gn.id}>#{gn.name}</option>')
	  $('.select_option').show()
  	"
  end
end
