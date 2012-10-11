class DataSilo < ActiveRecord::Base
  # attr_accessible :title, :body
    attr_accessible :sid, :url, :rip, :country, :state, :browser, :browser_version, :agent
end
