class Section < ActiveRecord::Base
#associations
has_many :subsections

def section_code_and_title
   ref.to_s<<' '<<text.to_s
end


end
