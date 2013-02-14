class Productimport < ActiveRecord::Base
#associations
  belongs_to :user
  
  has_attached_file :csv
   
  
  Paperclip.interpolates :normalized_video_file_name do |attachment, style|
    attachment.instance.normalized_image_file_name
  end

  def normalized_video_file_name
    "#{self.id}-#{self.video_image_name.gsub( /[^a-zA-Z0-9_\.]/, '_')}"
  end
  
  validates_attachment_presence :csv
  #validates_attachment :csv,
 # :attachment_content_type => { :content_type => ["text/csv"] }


end
