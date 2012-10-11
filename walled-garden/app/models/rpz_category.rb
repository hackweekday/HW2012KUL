class RpzCategory < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name
  has_many :rpz_domains
end
