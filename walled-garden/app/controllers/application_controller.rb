class ApplicationController < ActionController::Base
  protect_from_forgery
  
  layout :layout


  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      if current_user.admin
      	admin_domains_path
      else
      	usr_test_index_path
      end
    else
      super
    end
     #if (request.referer == "/users/sign_in")
        #omains_path
        #root_path
     #else
        #request.referer
        #domains_path
      #end
  end

  private

   # Overwriting the sign_out redirect path method
  #def after_sign_out_path_for(resource_or_scope)
  #  root_path
  #end

  #def sign_in
  #	if user_signed_in?
  #		redirect_to new_user_session_path
  #	end
  #end

  def layout
  	#is_a?(RegistrationsController)
    if is_a?(Devise::SessionsController) || is_a?(Devise::ConfirmationsController) || is_a?(Devise::PasswordsController)
      "login"
    #elsif is_a?(AuthenticationsController)
    #"first_time"
    else
      "application"
    end
  end 

end
