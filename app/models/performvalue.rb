class Performvalue < ActiveRecord::Base
  #associations  
    has_many :performs
    belongs_to :performtxt
    #
    belongs_to :valuetype
  # attr_accessible :title, :body
  
  def full_perform_value
    if valuetype_id == nil
      performtxt.text      
    else
      if valuetype.unit_id == nil
        if valuetype.standard_id == nil
          performtxt.text 
        else  
          performtxt.text << ' to ' << valuetype.standard.ref
        end     
      else        
        if valuetype.standard_id == nil
          performtxt.text << valuetype.unit.text
        else
          performtxt.text << valuetype.unit.text << ' to ' << valuetype.standard.ref   
        end   
      end                
    end
  end
  
end
