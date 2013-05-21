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

def project_code
   code
end

  Paperclip.interpolates :normalized_video_file_name do |attachment, style|
    attachment.instance.normalized_image_file_name
  end

  def normalized_video_file_name
    "#{self.id}-#{self.video_image_name.gsub( /[^a-zA-Z0-9_\.]/, '_')}"
  end



validates_presence_of :code
validates_presence_of :title

validates_attachment :photo,
  :attachment_content_type => { :content_type => ["image/png", "image/jpg"] },
  :size => { :in => 0..1000.kilobytes }

end
