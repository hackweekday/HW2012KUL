class SessionsController < ApplicationController
  #before_filter :user_signed_in?, :only => [:delete]
  before_filter :require_login, :except => [:destroy, :new, :signout, :create]
  before_filter :only_admin, :except => [:destroy, :new, :signout, :create]
  before_filter :set_timezone, :except => [:destroy, :new, :signout, :create]

  layout 'login'
 
  def create
    user = login(params[:username], params[:password], params[:remember_me])
    if user
      session[:user_id] = user.id
      redirect_back_or_to root_path
    else
      flash.now.alert = "Invalid credentials!"
      render :new
    end
  end
 
  def delete
    session.delete(:user_id)
  end

  def new
    respond_to do |f|
      f.js { render :js => "window.location = '#{root_path}'" } 
      f.html { }
    end
  end

  def destroy
    session.delete(:user_id)
  end

  def signout
    session.delete(:user_id)
    logout
    redirect_to new_session_url
    #, :notice => "You have been logged out."
    #session.delete(:user_id)
    #flash[:notice] = "signed out"
    #redirect_to new_session_url
  end

  def show
  end


end
