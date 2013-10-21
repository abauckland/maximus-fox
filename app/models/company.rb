class Company < ActiveRecord::Base

has_many :users
has_many :accounts
has_attached_file :photo
accepts_nested_attributes_for :accounts
accepts_nested_attributes_for :users




  attr_accessor :check_field  


  before_validation :custom_validation_check_field, on: :create


  Paperclip.interpolates :normalized_video_file_name do |attachment, style|
    attachment.instance.normalized_image_file_name
  end

  def normalized_video_file_name
    "#{self.id}-#{self.video_image_name.gsub( /[^a-zA-Z0-9_\.]/, '_')}"
  end

validates :read_term,
          on: :create, 
          :acceptance => { :accept => 1 }

validates :company_name,
          on: :create,    
          :presence => true,   
          :length => {:minimum => 3, :maximum => 254},
          :uniqueness => {:message => "An account for the company already exists, please contact your administrator"} 
          

validates :tel,
          on: :create,    
          :presence => true

validates_attachment :photo,
  :attachment_content_type => { :content_type => ["image/png", "image/jpg"] },
  :size => { :in => 0..1000.kilobytes },
  if: "photo.nil?"


  def custom_validation_check_field
    if @check_field !=''
      errors.add(:field_check, "Cannot be blank")
    end     
  end  


end
