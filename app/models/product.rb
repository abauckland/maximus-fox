class Product < ActiveRecord::Base
#associations
  has_many :characteristics
  belongs_to :user
  belongs_to :productgroup
end
