class Range < ActiveRecord::Base
#associations
  belongs_to :clause
  belongs_to :txt4
  has_many :products

end
