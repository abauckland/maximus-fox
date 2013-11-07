class Performance < ActiveRecord::Base
#associations
  has_many :characteristics
  has_many :txt6units, :through => :performtxt6units
  belongs_to :txt3
end
