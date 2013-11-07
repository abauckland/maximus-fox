class Productclause < ActiveRecord::Base
#associations
  belongs_to :productgroup
  belongs_to :clause

end
