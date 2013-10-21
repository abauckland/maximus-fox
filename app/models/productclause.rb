class Productclause < ActiveRecord::Base
#associations
  belongs_to :product
  belongs_to :clause

end
