class User < ActiveRecord::Base

belongs_to :company
has_one :licence
has_many :productimport



  attr_accessible :first_name, :surname, :email, :company_id, :role, :company, :password, :check_field
  attr_accessor :password, :check_field  
  before_save :encrypt_password  
  after_create :add_user_to_mailchimp
  

    
  validates_confirmation_of :first_name
  validates_confirmation_of :surname

  validates :password,   
            :presence => {:message => "can't be black"},
            on: :create,   
            :length => {:minimum => 8, :message => "must be minimum 8 characters long"} 
    
  validates :email,   
            :presence => true,
            on: :create,   
            :uniqueness => {:message => "A user with this email address already exists"},
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
    mailchimp = Gibbon::API.new('4d0b1be76e0e5a65e23b00efa3fe8ef3-us5')
  
    mailchimp.lists.subscribe({:id => 'c65ee7deb5', :email => {:email => self.email}, :merge_vars => {:FNAME => self.first_name, :LNAME => self.surname}, :double_optin => false, :send_welcome => true, })
    mailchimp.lists.subscribe({:id => '01239b3a0f', :email => {:email => self.email}, :merge_vars => {:FNAME => self.first_name, :LNAME => self.surname}, :double_optin => false, :send_welcome => true, })    
  end


end
