class Company < ActiveRecord::Base

has_many :users
has_many :accounts
has_attached_file :photo
accepts_nested_attributes_for :accounts
accepts_nested_attributes_for :users

validates :read_term,
          :acceptance => { :accept => 1 }

validates :company_name,   
          :presence => true,   
          :length => {:minimum => 3, :maximum => 254},
          :uniqueness => {:message => "An account for the company already exists, please contact your administrator"} 
          

validates :tel,   
          :presence => true

end
