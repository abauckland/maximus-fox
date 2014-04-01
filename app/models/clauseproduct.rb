class Clauseproduct < ActiveRecord::Base
#associations  
  belongs_to :clause
  belongs_to :product
end
