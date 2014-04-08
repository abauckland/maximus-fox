class Perform < ActiveRecord::Base
#associations    
  has_many :charcs
  has_many :instances, :through => :charcs
  
  belongs_to :performkey
  belongs_to :performvalue
end
