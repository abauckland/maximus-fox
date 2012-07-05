module SpeclinesHelper

def clause_row_class(clause, current_project)

check_clause_use = Specline.where('clause_id =? AND project_id = ?', clause.id, current_project) 
if check_clause_use.blank?
"clause_full".html_safe
else
"clause_partial".html_safe
end
end

def mob_line_display(specline)

  case specline.linetype_id
    
      when 3 ; "<li class='sep'>Text-1</li><li >f.text_field :specline.txt5_text</li>".html_safe
  
      when 4 ; "<li class='sep'>Text-1</li><li >f.text_field :specline.txt4_text</li><li class='sep'>Text-1</li><li >f.text_field :specline.txt5_text</li>".html_safe
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
      when 5 ; "<li class='sep'>Text-1</li><li >f.text_field :specline.txt3_text</li><li class='sep'>Text-1</li><li >f.text_field :specline.txt6_text</li>".html_safe

      when 6 ; "<li class='sep'>Text-1</li><li >f.text_field :specline.txt3_text</li><li class='sep'>Text-1</li><li >f.text_field :specline.txt5_text</li>".html_safe

      when 7 ; "<li class='sep'>Text-1</li><li >f.text_field :specline.txt4_text</li>".html_safe
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
      when 8 ; "<li class='sep'>Text-1</li><li >f.text_field :specline.txt4_text</li><li class='sep'>Text-1</li><li >f.text_field :specline.txt5_text</li>".html_safe

  end


end


 
  
end
