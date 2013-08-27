class Txt3unit < ActiveRecord::Base
#associations

has_many :performances
belongs_to :txt3
belongs_to :unit
end
