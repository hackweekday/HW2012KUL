class DataSeed < ActiveRecord::Base
  attr_accessible :subscriber_id, :ip_address_id, :url, :rip, :browser, :browser_version, :agent
  belongs_to :subscriber
  belongs_to :ip_address
end
