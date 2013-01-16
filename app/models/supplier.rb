class Supplier < ActiveRecord::Base
  has_many :productgroups
  has_many :sponsors
  has_attached_file :photo
end
