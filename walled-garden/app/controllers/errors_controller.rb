class ErrorsController < ApplicationController
  def routing
    #render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    redirect_to error_404_path
  end

  def error_404
  end
end