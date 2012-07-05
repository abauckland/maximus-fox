class Clauseref < ActiveRecord::Base
#associations
belongs_to :subsection, :include => [:section]
belongs_to :clausetype

has_many :clauses

validate :custom_validation_1

  # Getter
  def full_clause_ref
    [clausetype_id, clause, subclause].join('')
  end


  # Setter
  def full_clause_ref=(code)    
    self.clausetype_id = code[0,1]
    #variables required to calculate length of reference
      @clauseref_clausetype_id = code[0,1]
    self.clause = code[1,2]
      @clauseref_clause = code[1,2]
    self.subclause = code[3,1]
      @clauseref_subclause = code[3,1]
      @clauseref_extra = code[4,1]
  end



  def custom_validation_1

  #length of reference has to use variables to calculate the number digits because where the first digit of the clause reference is a '0' then this is dropped mking it impossible to calculate the length of the reference entered
    if @clauseref_clausetype_id
      a = @clauseref_clausetype_id.length
    else
      a = 0
    end

    if @clauseref_clause
      b = @clauseref_clause.length
    else
      b = 0
    end

    if @clauseref_subclause
      c = @clauseref_subclause.length
    else
      c = 0
    end

    if @clauseref_extra
      d = @clauseref_extra.length
    else
      d = 0
    end

    ref_length = a + b + c + d

    if ref_length != 4    
      errors.add(:full_clause_ref, '4 digit reference required')
    end 

    if ['1','2','3','4','5','6'].include?(@clauseref_clausetype_id) != true 
      errors.add(:full_clause_ref, "First digit must be between 1 and 6")
    end 
  
    if is_number(@clauseref_clause)
    else
      errors.add(:full_clause_ref, "Reference must be numerical")
    end   
  
    if is_number(@clauseref_subclause)
    else
      errors.add(:full_clause_ref, "Reference must be numerical")
    end         
  end

  def is_number(check_item)
    true if Float(check_item) rescue false
  end

end
