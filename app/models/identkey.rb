class Identkey < ActiveRecord::Base
  #associations
    has_many :identities
  # attr_accessible :title, :body
end
