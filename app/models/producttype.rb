class Producttype < ActiveRecord::Base
#associations  
  has_many :products
  # attr_accessible :title, :body
end
