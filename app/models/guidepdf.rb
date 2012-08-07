class Guidepdf < ActiveRecord::Base
has_many :subsections
has_many :guidedownloads
has_attached_file :pdf

validates_attachment_content_type :pdf, :content_type => ['application/pdf']
end
