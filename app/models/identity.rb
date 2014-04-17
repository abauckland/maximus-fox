class Identity < ActiveRecord::Base
  #associations  
    has_many :descripts
    has_many :products, :through => :descripts

    has_many :speclines
    has_many :changes
      
    belongs_to :identvalue
    belongs_to :identkey
  # attr_accessible :title, :body
end
