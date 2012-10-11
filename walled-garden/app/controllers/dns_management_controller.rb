class DnsManagementController < ApplicationController
  set_tab :zone_management
  set_tab :acl, :first_level, :only => %w(acl)
  set_tab :global_options, :first_level, :only => %w(global_options)
  
  def index  
  end
  
  def acl
     render :layout => 'application_without_sidebar'
  end

  def global_options
     render :layout => 'application_without_sidebar'
  end
end
