class Txt6unit < ActiveRecord::Base
#associations

has_many :performances, :through => :performtxt6units
belongs_to :txt6
belongs_to :unit
belongs_to :standard
end
