class Priceplan < ActiveRecord::Base
  has_many :planfeatures
  accepts_nested_attributes_for :planfeatures

  attr_accessible :name, :price

end
