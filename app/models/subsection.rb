class Subsection < ActiveRecord::Base
#associations
has_many :clauserefs
has_many :sponsors
belongs_to :section
belongs_to :guidepdf

def subsection_code
    section.ref.to_s + sprintf("%02d", ref).to_s
end


def subsection_full_code_and_title
    section.ref.to_s + sprintf("%02d", ref).to_s + ' ' + text.to_s
end

def subsection_code_and_title
    sprintf("%02d", ref).to_s + ' ' + text.to_s
end

end
