class Association < ActiveRecord::Base

  belongs_to :clause
  belongs_to :associate, :class_name => "Clause"

end
