class Performance < ActiveRecord::Base
#associations
  has_many :characteristics
  belongs_to :txt3
  belongs_to :txt6
end
