class IpAddress < ActiveRecord::Base
  attr_accessible :address, :country, :stateprov, :city, :latitude, :longitude, :tz_offset, :tz_name, :isp, :ctype, :organization
  has_many :data_seeds
end
