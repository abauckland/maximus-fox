class Sponsor < ActiveRecord::Base
  belongs_to :subsection
  belongs_to :supplier
  
end
