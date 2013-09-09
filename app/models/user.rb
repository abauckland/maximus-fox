class User < ActiveRecord::Base

belongs_to :company
has_one :licence
has_many :productimport



  attr_accessible :first_name, :surname, :email, :company_id, :role, :company, :password, :check_field
  attr_accessor :password, :check_field  
  before_save :encrypt_password  
  after_create :add_user_to_mailchimp
  
  before_validation :custom_validation_check_field

    
  validates_confirmation_of :first_name
  validates_confirmation_of :surname  

  validates :password,   
            :presence => {:message => "can't be black"},   
            :length => {:minimum => 8, :message => "must be minimum 8 characters long"} 
    
  validates :email,   
            :presence => true,   
            :uniqueness => {:message => "A user with this email address already exists"},
            :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }  
      

  def custom_validation_check_field
    if @check_field !=''
#      errors.add(:field_check, "Clause title cannot be blank")
    end     
  end  
  
  def encrypt_password  
    if password.present?  
      self.password_salt = BCrypt::Engine.generate_salt  
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)  
    end  
  end 
  
  def self.authenticate(email, password)  
    user = find_by_email(email)  
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
    user  
    else  
      nil  
    end  
  end 

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end 

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end


  
  def add_user_to_mailchimp  
    mailchimp = Hominid::API.new('4d0b1be76e0e5a65e23b00efa3fe8ef3-us5')
    list_id = mailchimp.find_list_id_by_name('Specright Users')

    mailchimp.list_subscribe(list_id, self.email, {'FNAME' => self.first_name, 'LNAME' => self.surname}, 'html', false, false, false, true)
  end


end
