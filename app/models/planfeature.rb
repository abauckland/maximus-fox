class Planfeature < ActiveRecord::Base
belongs_to :priceplan

  attr_accessible :priceplan_id, :text

end