class Change < ActiveRecord::Base
#associations
belongs_to :revision
belongs_to :project
belongs_to :specline
belongs_to :linetype

belongs_to :txt1
belongs_to :txt2
belongs_to :txt3
belongs_to :txt4
belongs_to :txt5
belongs_to :txt6

belongs_to :user

end
