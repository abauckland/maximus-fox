class Characteristic < ActiveRecord::Base
#associations
  belongs_to :product
  belongs_to :performance
end
