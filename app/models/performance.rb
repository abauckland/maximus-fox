class Performance < ActiveRecord::Base
#associations
  has_many :characteristics
  belongs_to :txt3unit
  belongs_to :txt6
  has_many :standardperformances
end
