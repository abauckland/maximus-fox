class Product < ActiveRecord::Base
#associations
  belongs_to :range
  has_many :characteristics

end
