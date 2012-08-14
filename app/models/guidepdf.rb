class Guidepdf < ActiveRecord::Base
has_many :subsections
has_many :guidedownloads
has_attached_file :photo

validates_attachment_content_type :photo, :content_type => ['application/pdf']
end
