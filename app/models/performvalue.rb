class Performvalue < ActiveRecord::Base
  #associations  
    has_many :performs
    belongs_to :performtxt
    #
    belongs_to :valuetype
  # attr_accessible :title, :body
end
