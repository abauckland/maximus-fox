class Txt4 < ActiveRecord::Base
#associations
has_many :speclines
has_many :changes

#validation                                                 
#validates_uniqueness_of :id
#validates_uniqueness_of :text
# does not work as it check uniqueness of each column and not combination of columns


end
