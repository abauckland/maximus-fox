def revisions(current_project, selected_revision, project_status_changed, previous_revision_project_status, current_revision_project_status, array_of_new_subsections_compacted, array_of_deleted_subsections_compacted, array_of_changed_subsections_compacted, hash_of_deleted_clauses, hash_of_new_clauses, hash_of_changed_clauses)


#font styles for page  
  font_style_section_title =          {:size => 16, :style => :bold}
  font_style_clausetype_code_title =  {:size => 11, :style => :bold}
  font_style_rev_section_action =     {:size => 12, :style => :bold_italic}
  
  font_style_rev_section_title =      {:size => 11}
  font_style_rev_clause_action =      {:size => 11, :style => :bold}
  font_style_rev_clause_code_title =  {:size => 11, :style => :bold}
  font_style_rev_line_action =        {:size => 9, :style => :bold_italic}
  font_style_rev_line_sub_action =    {:size => 8, :style => :italic}
 
#formating for lines  
  section_title_format = font_style_section_title.merge(section_title_dims)
  clausetype_code_format = font_style_clausetype_code_title.merge(clausetype_code_dims)
  clausetype_title_format = font_style_clausetype_code_title.merge(:width => 155.mm, :overflow => :expand)
  
  rev_section_action_format = font_style_rev_section_action.merge(:width => 50.mm)
  rev_section_title_format = font_style_rev_section_title.merge(:width => 158.mm, :overflow => :expand)
  rev_clause_action_format = font_style_rev_clause_action.merge(:width => 100.mm)
  rev_clause_title_format = font_style_rev_clause_code_title.merge(:width => 135.mm, :overflow => :expand)
  rev_clause_code_format = font_style_rev_clause_code_title.merge(:width => 20.mm)
  rev_line_action_format = font_style_rev_line_action.merge(:width => 50.mm)
  rev_line_sub_action_format = font_style_rev_line_sub_action.merge(:width => 20.mm)   


    pdf.start_new_page
    pdf.y = 268.mm

    @rev_start_bookmark = []
    @rev_start_bookmark[0] = pdf.page_number


    pdf.spec_box "Document Revisions", section_title_format.merge(:at => [0.mm, pdf.y])
    pdf.move_down(pdf.box_height + 2.mm)


if project_status_changed
  pdf.spec_box "Document Status Changed from #{previous_revision_project_status} to #{current_revision_project_status}:", :size => 11, :at => [0.mm, pdf.y], :width => 165.mm, :height => 7.mm;
  pdf.move_down(pdf.box_height + 2.mm)
end



  
if !array_of_new_subsections_compacted.blank?;  
  #save y position to refernce after dry run
  y_position = pdf.y
  
  #check will fit on page   
  pdf.draft_text_box "Subsections added:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.draft_box_height + 2.mm)   
  
  check_rev_prelim_title_fit(array_of_new_subsections_compacted, rev_section_title_format, pdf)  
  array_of_new_subsections_compacted.each do |subsection|  
    check_rev_section_changes_fit(subsection, rev_section_title_format, pdf)
  end      
  
  #start new page if does not fit or reset y value         
  check_new_page(y_position, pdf)     
  
  #print list of subsections added
  pdf.spec_box "Subsections added:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.box_height + 2.mm) 
  
  print_rev_prelim_title(array_of_new_subsections_compacted, rev_section_title_format, pdf)  
  array_of_new_subsections_compacted.each do |subsection|  
    print_rev_section_changes(subsection, rev_section_title_format, pdf)
  end    
end


if !array_of_deleted_subsections_compacted.blank? 
  #save y position to refernce after dry run
  y_position = pdf.y
  
  #check will fit on page 
  pdf.draft_text_box "Subsections deleted:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.draft_box_height + 2.mm) 
  
  check_rev_prelim_title_fit(array_of_deleted_subsections_compacted, rev_section_title_format, pdf)  
  array_of_deleted_subsections_compacted.each do |subsection|  
    check_rev_section_changes_fit(subsection, rev_section_title_format, pdf)
  end      
  
  #start new page if does not fit or reset y value         
  check_new_page(y_position, pdf)     
  
  #print list of subsections added
  pdf.spec_box "Subsections deleted:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.box_height + 2.mm)
  
  print_rev_prelim_title(array_of_deleted_subsections_compacted, rev_section_title_format, pdf)
  array_of_deleted_subsections_compacted.each do |subsection|  
    print_rev_section_changes(subsection, rev_section_title_format, pdf)
  end   
end


if !array_of_changed_subsections_compacted.blank?
  #save y position to refernce after dry run
  y_position = pdf.y
  
  #check title will fit on page   
  pdf.draft_text_box "Subsections changed:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.draft_box_height + 2.mm)   
  
  check_rev_section_changes_fit(subsection, rev_section_title_format, pdf)
  
  #start new page if does not fit or reset y value
  if pdf.y <= 16.mm
    pdf.start_new_page
    pdf.y = 268.mm
  else
    pdf.y = y_position   
  end  
  
  
  pdf.spec_box "Subsections changed:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.box_height + 2.mm)

  print_rev_prelim_title(array_of_changed_subsections_compacted, rev_section_title_format, pdf)


###next line in wrong place
  array_of_changed_subsections_compacted.each do |changed_subsection|
 
    print_rev_section_changes(changed_subsection, rev_section_title_format, pdf)

    if !hash_of_deleted_clauses[changed_subsection.id].blank?
      
      hash_of_deleted_clauses_compacted = hash_of_deleted_clauses[changed_subsection.id].compact
      #save y position to refernce after dry run
      y_position = pdf.y      

      #check will fit on page 
      pdf.draft_text_box "Subsection clauses deleted:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.daft_box_height + 2.mm)      
      hash_of_deleted_clauses_compacted.each do |clause|         
        draft_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)
      end         

      #start new page if does not fit or reset y value         
      check_new_page(y_position, pdf)
       
      #print list of text deleted from clasue            
      pdf.spec_box "Subsection clauses deleted:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm)
      hash_of_deleted_clauses_compacted.each do |clause|                
        print_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)            
      end
    end
 

    if !hash_of_new_clauses[changed_subsection.id].blank?
      
      hash_of_new_clauses_compacted = hash_of_new_clauses[changed_subsection.id].compact
      #save y position to refernce after dry run
      y_position = pdf.y

      #check will fit on page 
      pdf.draft_text_box "Subsection clauses added:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.daft_box_height + 2.mm)      
      hash_of_new_clauses_compacted.each do |clause|         
        draft_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)
      end         

      #start new page if does not fit or reset y value         
      check_new_page(y_position, pdf) 

      #print list of text deleted from clasue  
      pdf.spec_box "Subsection clauses added:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm)
      hash_of_new_clauses_compacted.each do |clause|         
        print_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)
      end     
    end



    if !hash_of_changed_clauses[changed_subsection.id].blank?
      pdf.spec_box "Subsection clauses changed:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm)
      hash_of_changed_clauses_compacted = hash_of_changed_clauses[changed_subsection.id].compact

####STILL TO CHECK      
      hash_of_changed_clauses_compacted.each do |clause|
        print_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)

            
        deleted_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', current_project.id, clause, selected_revision.id, 'deleted')
        if deleted_lines
          #save y position to refernce after dry run
          y_position = pdf.y
          
          #check will fit on page
          pdf.draft_text_box "Text deleted:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
          pdf.move_down(pdf.draft_box_height + 1.mm)
          
          deleted_lines.each do |deleted_line|      
              rev_line_draft(line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)                            
          end
          
          #start new page if does not fit or reset y value         
          check_new_page(y_position, pdf)           
          
          #print list of text deleted from clasue
          pdf.spec_box "Text deleted:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
          pdf.move_down(pdf.box_height + 1.mm)          
          
          deleted_lines.each do |deleted_line|
              rev_line_print(line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)      
          end
        end

        added_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', current_project.id, clause, selected_revision.id, 'new')
        if added_lines
          #save y position to refernce after dry run
          y_position = pdf.y
          
          #check will fit on page
          pdf.draft_text_box "Text added:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
          pdf.move_down(pdf.draft_box_height + 1.mm)
          
          added_lines.each do |added_line|      
              rev_line_draft(line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)                            
          end
          
          #start new page if does not fit or reset y value         
          check_new_page(y_position, pdf) 
                      
          #print list of text added to clasue
          pdf.spec_box "Text added:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
          pdf.move_down(pdf.box_height + 1.mm)
          
          added_lines.each do |added_line|      
              rev_line_print(line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)                            
          end
        end


       changed_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', current_project.id, clause, selected_revision.id, 'changed')
        if changed_lines
          check_changed_print_status = changed_lines.collect{|item| item.print_change}.uniq
          if check_changed_print_status.include?(true)
            
            #save y position to refernce after dry run
            y_position = pdf.y            

            #check will fit on page
            pdf.draft_text_box "Text changed:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
            pdf.move_down(pdf.draft_box_height + 1.mm)
          
            changed_lines.each do |changed_line|
#check this is correct
              subsequent_change = Change.where('id > ? AND specline_id = ?', changed_line.id, changed_line.specline_id).first 
              if subsequent_change
                previous_line = subsequent_change                
              else
                current_line = Specline.find(changed_line.specline_id)    
              end
                    
              pdf.draft_text_box "From:", rev_line_sub_action_format.merge(:at =>[35.mm, pdf.y])
              pdf.move_down(pdf.box_height)
              
              rev_line_draft(previous_line, pdf)
              pdf.move_down(pdf.draft_box_height)
                            
              pdf.draft_text_box "To:", rev_line_sub_action_format.merge(:at =>[35.mm, pdf.y])
              pdf.move_down(pdf.box_height)
              
              rev_line_draft(current_line, pdf)
              pdf.move_down(pdf.draft_box_height + 2.mm)
                                                        
            end
            
            #start new page if does not fit or reset y value         
            check_new_page(y_position, pdf)                         
   
            #print list of text changed in clasue
            pdf.spec_box "Text changed:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
            pdf.move_down(pdf.box_height + 1.mm)
         
            changed_lines.each do |changed_line|;
#check this is correct
              subsequent_change = Change.where('id > ? AND specline_id = ?', changed_line.id, changed_line.specline_id).first 
              if subsequent_change
                previous_line = subsequent_change                
              else
                current_line = Specline.find(changed_line.specline_id)    
              end
              
              pdf.spec_box "From:", rev_line_sub_action_format.merge(:at =>[35.mm, pdf.y])
              pdf.move_down(pdf.box_height)
                
              rev_line_print(previous_line, pdf)
              pdf.move_down(pdf.box_height)

              pdf.spec_box "To:", rev_line_sub_action_format.merge(:at =>[35.mm, pdf.y])
              pdf.move_down(pdf.box_height)
                                 
              rev_line_print(current_line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)                     
            end        

          else
            #save y position to refernce after dry run
            y_position = pdf.y            

            #check will fit on page            
            pdf.draft_text_box "Text changed:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
            pdf.move_down(pdf.draft_box_height)            
            
            pdf.draft_text_box "Some minor spelling and grammatical changes have been made to this clause. For this reason revision details have not been recorded.", :size => 10, :style => :italic, :at =>[35.mm,rev_row_y_b], :width => 140.mm, :height => 5.mm, :overflow => :expand;
            pdf.move_down(pdf.draft_box_height + 2.mm)            
            
            #start new page if does not fit or reset y value         
            check_new_page(y_position, pdf)                       
   
            #print list of text changed in clasue           
            pdf.spec_box "Text changed:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
            pdf.move_down(pdf.box_height)            
            
            pdf.spec_box "Some minor spelling and grammatical changes have been made to this clause. For this reason revision details have not been recorded.", :size => 10, :style => :italic, :at =>[35.mm,rev_row_y_b], :width => 140.mm, :height => 5.mm, :overflow => :expand;
            pdf.move_down(pdf.box_height + 2.mm) 
          end
        end
      end
    end
  end
end



@rev_end_bookmark = [];
@rev_end_bookmark[0] = pdf.page_number;

end


def check_new_page(y_position, pdf)  
  if pdf.y <= 16.mm
    pdf.start_new_page
    pdf.y = 268.mm
  else
    pdf.y = y_position   
  end   
end



def print_rev_prelim_title(subsections, format, pdf)  
    if subsections.first.section_id == 1   
      pdf.spec_box "A-- Preliminaries:", format.merge(:at => [5.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm) 
    end
end


def check_rev_prelim_title_fit(subsections, format, pdf)  
  if subsections.first.section_id == 1   
    pdf.draft_text_box "A-- Preliminaries:", format.merge(:at => [5.mm, pdf.y])
    pdf.move_down(pdf.draft_box_height + 2.mm) 
  end
end

def print_rev_prelim_title(subsections, format, pdf)  
    if subsections.first.section_id == 1   
      pdf.spec_box "A-- Preliminaries:", format.merge(:at => [5.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm) 
    end
end

def check_rev_section_changes_fit(subsection, format, pdf)    
    if subsection.section_id == 1
      x = 7.mm
    else
      x = 5.mm 
    end
    pdf.draft_text_box "#{subsection.subsection_full_code_and_title}", format.merge(:at => [x, pdf.y])
    pdf.move_down(pdf.draft_box_height + 2.mm)   
end

def print_rev_section_changes(subsection, format, pdf)      
    if subsection.section_id == 1
      x = 7.mm
    else
      x = 5.mm 
    end
    pdf.spec_box "#{subsection.subsection_full_code_and_title}", format.merge(:at => [x, pdf.y])
    pdf.move_down(pdf.box_height + 2.mm)     
end

def draft_rev_clause_code_title (clause, format_code, format_title, pdf)
    pdf.spec_box "#{clause.clause_code}", format_code.merge(:at => [15.mm, pdf.y])
    pdf.spec_box "#{clause.clausetitle.text}", format_title.merge( :at => [35.mm, pdf.y])
    pdf.move_down(pdf.box_height + 2.mm)
end

def print_rev_clause_code_title (clause, format_code, format_title, pdf)
    pdf.spec_box "#{clause.clause_code}", format_code.merge(:at => [15.mm, pdf.y])
    pdf.spec_box "#{clause.clausetitle.text}", format_title.merge( :at => [35.mm, pdf.y])
    pdf.move_down(pdf.box_height + 2.mm)
end


