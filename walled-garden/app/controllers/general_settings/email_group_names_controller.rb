class GeneralSettings::EmailGroupNamesController < ApplicationController
  def new
    @group = EmailGroupName.new
  end

  def edit
    @group = EmailGroupName.find(params[:id])
    render 'new.js'
  end

  def create
    @group = EmailGroupName.new(params[:email_group_name])
      if @group.save
        all_group
        all_recipient
      else
        render :js => "show_error(eval(#{@group.errors.full_messages}))"
      end
  end

  def update
    @group = EmailGroupName.find(params[:id])

      if @group.update_attributes(params[:email_group_name])
      	@groups = EmailGroupName.all
        all_recipient
        render 'create.js'
      else
        render :js => "show_error(eval(#{@group.errors.full_messages}))"
      end
  end

  def destroy
    @group = EmailGroupName.find(params[:id])
    @group.destroy
    all_group
    all_recipient
    render 'create.js'
  end

  def all_group
    @groups = EmailGroupName.all
  end

  def all_recipient
    @emails = Email.order("created_at desc")
  end
end
