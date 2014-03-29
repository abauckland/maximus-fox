class Standard < ActiveRecord::Base

has_many :performvalues
has_many :standardsubsections

  def standard_ref_and_title
    ref + ' ' + title
  end

end
