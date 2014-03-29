class Product < ActiveRecord::Base
#associations  
  has_many :clauseproducts
  has_many :descripts
  has_many :identities, :through => :descripts
  has_many :instances
  belongs_to :producttype
end
