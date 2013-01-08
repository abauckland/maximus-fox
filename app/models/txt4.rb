class Txt4 < ActiveRecord::Base
#associations
has_many :speclines
has_many :changes
has_many :ranges

end
