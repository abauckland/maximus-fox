class Comment < ActiveRecord::Base
belongs_to :post

  attr_accessible :post_id, :author, :email, :text, :check_field
  attr_accessor :check_field 

  before_validation :custom_validation_check_field

  def custom_validation_check_field
    if @check_field !=''
#      errors.add(:field_check, "Clause title cannot be blank")
    end     
  end  

end
