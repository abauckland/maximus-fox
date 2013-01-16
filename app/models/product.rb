class Product < ActiveRecord::Base
#associations
  belongs_to :productgroup
  has_many :characteristics

end
