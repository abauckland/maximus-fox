class Revision < ActiveRecord::Base
#associations
belongs_to :project
has_many :changes

end
