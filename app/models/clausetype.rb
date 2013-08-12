class Clausetype < ActiveRecord::Base
#associations
has_many :clauserefs
has_many :lineclausetypes
end
