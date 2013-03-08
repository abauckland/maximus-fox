module ProjectsHelper



#establishes the identity of each edit_box tab
def class_and_href_ref(clausetype_id, current_clausetype_id)
  
  if clausetype_id == current_clausetype_id
  "class='selected' href='##{clausetype_id}edit_view'".html_safe
  else
  "href='##{clausetype_id}edit_view'".html_safe
  end
  
end

#list of clausetypes to generate tabs of edit_box
def clausetypes
    clausetypes = Clausetype.all
end



#switch statement to generate contents of each line depending on linetype_id
def clausetype_filter(specline, clausetype, selected)
  
##next line has been altered
  if clausetype == selected
  @line = specline
    
    case specline.linetype_id

      when 1, 2 ; "<table id='#{specline.id}' class='clause_title' width='100%'><tr class='specline_row'><td class='edit_box_code' width='85'>#{clause_ref_text(specline)}</td><td class='edit_box_title'>#{specline.clause.clausetitle.text}</td><td class='padding'></td><td class='specline_link' width ='120'>#{specline_line_new_link(specline)}#{clause_new_link(specline)}#{clause_delete_link(specline)}#{clause_help_link(specline)}</td></tr></table>".html_safe
    
      when 3 ; "#{html_prefix(specline)}  <td width='10px'></td><td class='prefix' width='18'>#{specline.txt1.text}.</td><td><span id='#{specline.id}' class='editable_text4'>#{specline.txt4.text}</span>: <span id='#{specline.id}'class='editable_text5'>#{specline.txt5.text}.</span></td>   <td class='padding'></td>#{specline_links(specline)}</tr></table>".html_safe

      when 4 ; "#{html_prefix(specline)}  <td width='10px'></td><td class='prefix' width='18'>#{specline.txt1.text}.</td><td><span id='#{specline.id}'class='editable_text4'>#{specline.txt4.text}.</span></td>    <td class='padding'></td>#{specline_links(specline)}</tr></table>".html_safe
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
      when 5 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td><table><tr><td><span id='#{specline.id}'class='editable_text3'>#{specline.txt3.text}</span></td><td>:</td><td width = '5'></td><td><span id='#{specline.id}'class='editable_text6'>#{specline.txt6.text}.</span></td></tr></table></td>   <td class='padding'></td>#{specline_links(specline)}</tr></table></td>".html_safe

      when 6 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td><table><tr><td><span id='#{specline.id}'class='editable_text3'>#{specline.txt3.text}</span></td><td>:</td><td width = '5'></td><td><span id='#{specline.id}'class='editable_text5'>#{specline.txt5.text}.</span></td></tr></table></td>   <td class='padding'></td>#{specline_links(specline)}</tr></table></td>".html_safe

      when 7 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td><span id='#{specline.id}'class='editable_text4'>#{specline.txt4.text}.</span></td>    <td class='padding'></td>#{specline_links(specline)}</tr></table>".html_safe
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
      when 8 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td><span id='#{specline.id}'class='editable_text4'>#{specline.txt4.text}</span>: <span id='#{specline.id}'class='editable_text5'>#{specline.txt5.text}.</span></td>   <td class='padding'></td>#{specline_links(specline)}</tr></table>".html_safe

    end
  end
end

def html_prefix(specline)
    "<table id='#{specline.id}' width='100%'><tr class='specline_row'><td class = 'pad' width = '90'>#{specline_move}</td>".html_safe
end

def specline_move
  image_tag("move.png", :mouseover =>"move_rollover.png", :border=>0)
end

def specline_links(specline)
   "<td class='specline_link' width ='120'>    #{specline_line_new_link(specline)}#{specline_line_edit_link(specline)}#{specline_line_delete_link(specline)}#{clause_manufact_link(specline)}  </td>".html_safe
end

def clause_ref_text(specline)                                                        
  specline.clause.clauseref.subsection.section.ref + sprintf("%02d", specline.clause.clauseref.subsection.ref).to_s<<"."<<specline.clause.clauseref.clausetype_id.to_s<<sprintf("%02d", specline.clause.clauseref.clause).to_s<<specline.clause.clauseref.subclause.to_s 
end

def clause_new_link(specline)
  link_to image_tag("new_clause.png", :mouseover =>"new_clause_rollover.png", :border=>0), {:controller => "speclines", :action => "manage_clauses", :id => specline.id, :subsection_id => specline.clause.clauseref.subsection_id, :clausetype_id => specline.clause.clauseref.clausetype_id}, :title => "add/delete clauses"
end
  
def clause_delete_link(specline)
  link_to image_tag("c_delete.png", :mouseover =>"c_delete_rollover.png", :border=>0), {:controller => "speclines", :action => "delete_clause", :id => specline.id}, :class => "delete", :title => "delete clause"
end
  
def specline_line_new_link(specline)
  link_to image_tag("insrow.png", :mouseover =>"insrow-rollover.png", :border=>0), {:controller => "speclines", :action => "new_specline", :id => specline.id}, :class => "get", :title => "insert clause line"
end
  
def specline_line_edit_link(specline)
  link_to image_tag("edit.png", :mouseover =>"edit_rollover.png", :border=>0), {:controller => "speclines", :action => "edit", :id => specline.id}, :class => "get", :title => "change line format"
end
  
def specline_line_delete_link(specline)
  link_to image_tag("delete.png", :mouseover =>"delete-rollover.png", :border=>0), {:controller => "speclines", :action => "delete_specline", :id => specline.id}, :class => "delete", :title => "delete line"
end

  
def clause_help_link(specline)
  check_clausehelp = specline.clause.guidenote_id
  if check_clausehelp > 1
     @check = specline.clause.guidenote.text

    if !@check.blank?
     link_to image_tag("help.png", :mouseover =>"help_rollover.png", :border=>0), {:controller => "speclines", :action => "guidance", :id => specline.clause_id, :spec_id => specline.id}, :class => "get", :title => "clause guidance"
    end
  end
end

##used where guidance notes generated from html
#def guidance_check(current_project_id, subsection_id)  
#  clause_guidance_check = Clause.joins(:clauseref).where('clauserefs.subsection_id = ? AND guidenote_id > ?', subsection_id, 0).first
#  if !clause_guidance_check.blank?
#  "<div id='guidance_button'>#{guidance_link(current_project_id, subsection_id)}</div>".html_safe  
#  end  
#end

def guidance_link(current_project_id, subsection_id)
 check_guide = Subsection.where(:id => subsection_id).first
  if !check_guide.guidepdf_id.nil?
    "<div id='guidance_button'>#{link_to 'guidance notes', {:controller => 'guidepdfs', :action => 'download', :id => check_guide.guidepdf_id}}</div>".html_safe
  end
end

def clause_manufact_link(specline)
end





#MOBILE HELPER METHODDS
#used for preliminaires section only
def get_subsection_speclines(current_project_id, subsection_id, clause_ids)

    array_of_selected_clauses = Clause.joins(:clauseref).where('clauses.id' => clause_ids, 'clauserefs.subsection_id' => subsection_id).collect{|item6| item6.id}.sort.uniq

   @selected_specline_lines = Specline.select('id, clause_id, clause_line, txt1_id, txt3_id, txt4_id, txt5_id, txt6_id, txt1s.id, txt1s.text, txt3s.id, txt3s.text, txt4s.id, txt4s.text, txt5s.id, txt5s.text, txt6s.id, txt6s.text, clauses.id, clauses.subsection_id, clauses.clausetype_id, clauses.clause, clauses.subclause, clauses.clausetitle_id, clauses.guidenote_id, clausetitles.id, clausetitles.text, subsections.id, subsections.ref, subsections.section_id, guidenotes.id, guidenotes.text').includes(:txt1, :txt3, :txt4, :txt5, :txt6, :clause => [:clausetitle, :guidenote, :clauseref => [:subsection]]).where(:project_id => @current_project.id, :clause_id => array_of_selected_clauses).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause, clause_line')                           

end


def mobile_filter(specline)
  
  @line = specline
    
    case specline.linetype_id

      when 1, 2 ; "<li id='#{specline.id}' class='clause_title'><table width =100%><tr><td width = '100'>#{clause_ref_text(specline)}</td><td>#{specline.clause.clausetitle.text}</td><td width='35'></td></tr></table></li>".html_safe
    
      when 3 ; "#{mob_html_prefix(specline)}  <td width='18'>#{specline.txt1.text}.</td><td>#{specline.txt4.text}: #{specline.txt5.text}.</td><td width='35'>#{mob_delete_line_link(specline)}</td></tr></table></li>".html_safe

      when 4 ; "#{mob_html_prefix(specline)}  <td width='18'>#{specline.txt1.text}.</td><td>#{specline.txt4.text}.</td><td width='35'>#{mob_delete_line_link(specline)}</td></tr></table></li>".html_safe
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
      when 5 ; "#{mob_html_prefix(specline)}  <td><table><tr><td>#{specline.txt3.text}:</td><td width = '5'></td><td>#{specline.txt6.text}.</td></tr></table></td><td width='35'>#{mob_delete_line_link(specline)}</td></tr></table></li>".html_safe

      when 6 ; "#{mob_html_prefix(specline)}  <td><table><tr><td>#{specline.txt3.text}:</td><td width = '5'></td><td>#{specline.txt5.text}.</td></tr></table></td><td width='35'>#{mob_delete_line_link(specline)}</td></tr></table></li>".html_safe

      when 7 ; "#{mob_html_prefix(specline)}  <td>#{specline.txt4.text}.</td><td width='35'>#{mob_delete_line_link(specline)}</td></tr></table></li>".html_safe
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
      when 8 ; "#{mob_html_prefix(specline)}  <td>#{specline.txt4.text}: #{specline.txt5.text}.</td><td width='35'>#{mob_delete_line_link(specline)}</td></tr></table></li>".html_safe

  end
end


def mob_html_prefix(specline)
    "<li id='#{specline.id}' class='specline_line'><table width =100%><tr><td width = '50'>#{mob_new_line_link(specline)}</td><td width='50'>#{mob_edit_line_link(specline)}</td>".html_safe
end

def mob_delete_clause_link(current_project, current_subsection_id, clause)
link_to "#{clause.clause_section_full_title}", {:controller => "speclines", :action => "mob_delete_clause", :id => @current_project.id, :del_clause_id => clause.id, :subsection_id => @current_subsection_id}, :class => "delete"
end

def mob_delete_line_link(specline)
link_to image_tag("delete_mob.png"),  {:controller => "speclines", :action => "mob_delete", :id => specline.id}, :class => "delete", :confirm => "Are you sure?"
end 

def mob_edit_line_link(specline)
link_to image_tag("edit_mob.png"), {:controller => "speclines", :action => "mob_edit_specline", :id => specline.project_id, :specline_id => specline.id}, :class => "small", :rel => "external"
end

def mob_new_line_link(specline)
link_to image_tag("insrow_mob.png"), {:controller => "speclines", :action => "mob_new_specline", :id => specline.id}, :class => "get"
end 



#end of class
end
