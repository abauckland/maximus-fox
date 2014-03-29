class Charc < ActiveRecord::Base
#associations
  belongs_to :product
  belongs_to :perform
end
