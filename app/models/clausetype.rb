class Clausetype < ActiveRecord::Base
#associations
has_many :clauserefs
has_many :lineclausetypes
has_many :subsections, :through => :clauserefs
end
