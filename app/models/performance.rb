class Performance < ActiveRecord::Base
#associations
  has_many :characteristics
  belongs_to :txt6unit
  belongs_to :txt3
end
