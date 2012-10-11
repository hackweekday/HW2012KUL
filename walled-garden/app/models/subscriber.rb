class Subscriber < ActiveRecord::Base
  attr_accessible :sid, :status
  has_many :data_seeds
  has_many :ip_addresses, :through => :data_seeds
end
