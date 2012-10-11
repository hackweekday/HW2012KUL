class RpzDomain < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :rpz_category_id, :domain, :status, :provider
  belongs_to :rpz_categories
end
