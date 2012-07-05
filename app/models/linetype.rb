class Linetype < ActiveRecord::Base
#associations
has_many :speclines
has_many :changes

#validation
validates_uniqueness_of :ref
#this is not case sensitive - need to load patch to fix this in rails 2.3 - https://rails.lighthouseapp.com/projects/8994/tickets/2503/a/128020/2503-add_case_sensitive_db.diff
# need to test functionality of validates_uniqueness_of


end
