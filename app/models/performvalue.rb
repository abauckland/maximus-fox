class Performvalue < ActiveRecord::Base
  #associations  
    has_many :performtxtarrays
    has_many :performtxts, :through => :performtxtarrays
    has_many :performs
    
    belongs_to :unit
    belongs_to :standard
  # attr_accessible :title, :body
end
