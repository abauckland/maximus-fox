class Productgroup < ActiveRecord::Base
#associations
  belongs_to :supplier  
  belongs_to :txt4
  has_many :products
  has_many :clauses, :through => :productclauses

end
