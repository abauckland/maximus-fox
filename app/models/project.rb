class Project < ActiveRecord::Base
#associations
belongs_to :company
has_many :clauses, :through => :speclines
has_many :revisions
has_many :changes
has_attached_file :photo 

def project_code_and_title
   code + ' ' + title
end

validates_presence_of :code
validates_presence_of :title
end
