class Product < ActiveRecord::Base
#associations
  belongs_to :user
  belongs_to :productgroup
end
