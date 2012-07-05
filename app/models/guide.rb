class Guide < ActiveRecord::Base
has_many :clauses
has_attached_file :pdf

validates_attachment_content_type :pdf, :content_type => ['application/pdf']
end
