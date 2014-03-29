class Performtxtarray < ActiveRecord::Base
  #associations     
    belongs_to :performvalue
    belongs_to :performtxt

  # attr_accessible :title, :body
end
