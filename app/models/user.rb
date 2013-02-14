class User < ActiveRecord::Base

belongs_to :company
has_one :licence
has_many :productimport



  attr_accessible :first_name, :surname, :email, :company_id, :role, :password, :password_confirmation, :company 
  attr_accessor :password  
  before_save :encrypt_password  
  after_create :add_user_to_mailchimp
  
    
  validates_confirmation_of :first_name
  validates_confirmation_of :surname 
  validates_confirmation_of :password  
  #validates_presence_of :password, :on => :create  
 
  validates_presence_of :password, :on => :create, :length => {:minimum => 8}
    
  validates :email,   
            :presence => true,   
            :uniqueness => true,
            :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }  
      
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
  
  def add_user_to_mailchimp  
    mailchimp = Hominid::API.new('4d0b1be76e0e5a65e23b00efa3fe8ef3-us5')
    list_id = mailchimp.find_list_id_by_name('Specright Users')

    mailchimp.list_subscribe(list_id, self.email, {'FNAME' => self.first_name, 'LNAME' => self.surname}, 'html', false, false, false, true)
  end


end
