class Guidepdf < ActiveRecord::Base
has_many :subsections
has_many :guidedownloads
has_attached_file :pdf

end