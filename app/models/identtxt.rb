class Identtxt < ActiveRecord::Base
  #associations
    has_many :identvalues 
  # attr_accessible :title, :body
end
