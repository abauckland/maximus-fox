module SpeclinesHelper

def clause_row_class(clause, current_project)

check_clause_use = Specline.where('clause_id =? AND project_id = ?', clause.id, current_project) 
if check_clause_use.blank?
"clause_full".html_safe
else
"clause_partial".html_safe
end
end
  
end
