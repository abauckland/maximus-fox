module RevisionsHelper

  def revision_select(project_revisions, selected_revision, current_project, revision_clause_id_array)

    if current_project.project_status == 'Draft'
      "<div id='revision_select_draft'>Project status is 'Draft', changes are not currently recorded</div>".html_safe
    else
      if revision_clause_id_array.blank?
        "<div id='revision_select'>#{revision_select_input(project_revisions, selected_revision, current_project)}</div>".html_safe
      else
        "<div id='revision_select'>#{revision_select_input(project_revisions, selected_revision, current_project)}</div>".html_safe
      end
    end
  end

  def revision_select_input(project_revisions, selected_revision, current_project)
    select_tag  "revision", options_from_collection_for_select(project_revisions, :id, :rev, selected_revision.id), :onchange => "window.location='/revisions/#{current_project.id}?revision='+this.value;"
  end


  def get_class_and_href_ref(subsection_id, current_subsection_id)
  
    if subsection_id == current_subsection_id
      "class='selected' href='##{subsection_id}rev_view'".html_safe
    else
      "href='##{subsection_id}rev_view'".html_safe
    end
  end
  
#prelim
#subsections titles of subsections added or deleted   
 def changed_prelim_subsection_text(changed_subsection)   
        "<table width='100%'><tr id='#{changed_subsection.id.to_s}' class='clause_title'><td class='changed_subsection_code'>#{changed_subsection.subsection_full_code_and_title.upcase}</td></tr></table>".html_safe 
 end
 
#prelim
#annotation for altered clauses
  def new_prelim_clauses_text(changed_subsection)  
      if !@hash_of_new_prelim_clauses[changed_subsection.id].blank?
            prelim_clauses_show(changed_subsection, 'added')
      end  
  end
  
  def deleted_prelim_clauses_text(changed_subsection)  
      if !@hash_of_deleted_prelim_clauses[changed_subsection.id].blank?
            prelim_clauses_show(changed_subsection, 'deleted')
      end  
  end
  
  def changed_prelim_clauses_text(changed_subsection)  
      if !@hash_of_changed_prelim_clauses[changed_subsection.id].blank?
            prelim_clauses_show(changed_subsection, 'changed')
      end  
  end
  
  def prelim_clauses_show(changed_subsection, action)
        "<table><tr><td class='rev_subsection_action'>Clauses #{action}:</td></tr></table>".html_safe
  end
  
#prelim  
#clause titles for added or deleted clauses   
  def changed_clause_titles(changed_clause, action)
    if !changed_clause.blank?
        rev_clause_title = Clause.find(changed_clause)

        #check print status
      if action != 'changed'
          "<table width='100%'><tr  id='#{rev_clause_title.id.to_s}' class='clause_title_2'><td class='rev_clause_code'>#{rev_clause_title.clauseref.subsection.section.ref.to_s}#{rev_clause_title.clauseref.subsection.ref.to_s}.#{rev_clause_title.clauseref.clausetype_id.to_s}#{rev_clause_title.clauseref.clause.to_s}#{rev_clause_title.clauseref.subclause.to_s}</td><td class ='rev_clause_title'>#{rev_clause_title.clausetitle.text.to_s}</td><td class='padding'></td><td class='specline_link'>#{reinstate_original_clause(rev_clause_title)}#{change_info_clause(rev_clause_title)}</td></tr></table>".html_safe    
      else

      check_clause_print_status = Change.find(:all, :conditions => {:project_id => @current_project, :clause_id => changed_clause, :revision_id => @selected_revision.id}).collect{|item| item.print_change}.uniq            
      if check_clause_print_status.include?(true)
        "<table><tr class='clause_title'><td class='changed_clause_code'>#{rev_clause_title.clauseref.subsection.section.ref.to_s}#{rev_clause_title.clauseref.subsection.ref.to_s}.#{rev_clause_title.clauseref.clausetype_id.to_s}#{rev_clause_title.clauseref.clause.to_s}#{rev_clause_title.clauseref.subclause.to_s}</td><td class ='changed_clause_title'>#{rev_clause_title.clausetitle.text.to_s}</td></tr></table>".html_safe    
      else
        "<table><tr class='clause_title_strike'><td class='changed_clause_code'>#{rev_clause_title.clauseref.subsection.section.ref.to_s}#{rev_clause_title.clauseref.subsection.ref.to_s}.#{rev_clause_title.clauseref.clausetype_id.to_s}#{rev_clause_title.clauseref.clause.to_s}#{rev_clause_title.clauseref.subclause.to_s}</td><td class ='changed_clause_title'>#{rev_clause_title.clausetitle.text.to_s}</td></tr></table>".html_safe    
      end
      end
    end
  end

#non prelim
#statement of if non prelim subsection has been added or deleted    
 def new_subsection_text(revision_subsection)   
    if @array_of_new_subsections[revision_subsection.id] == 'added'
        subsection_text_show(revision_subsection, 'added') 
    end
 end
 
 def deleted_subsection_text(revision_subsection)   
    if @array_of_deleted_subsections[revision_subsection.id] == 'deleted'
        subsection_text_show(revision_subsection, 'deleted') 
    end
 end
  
 def subsection_text_show(revision_subsection, action)
   "<table class='rev_deleted_subsection_title' width ='100%'><tr><td class='rev_title'>#{revision_subsection.subsection_full_code_and_title} #{action}.</td></tr></table>".html_safe 
 end

#non prelim
#set up anno for changed clauses
  def new_clauses_text(changed_subsection)  
      if !@hash_of_new_clauses[changed_subsection.id].blank?
           clauses_text_show(changed_subsection, 'added')
      end  
  end
  
  def deleted_clauses_text(changed_subsection)  
      if !@hash_of_deleted_clauses[changed_subsection.id].blank?
           clauses_text_show(changed_subsection, 'deleted')
      end  
  end
  
  def changed_clauses_text(changed_subsection)  
      if !@hash_of_changed_clauses[changed_subsection.id].blank?
           clauses_text_show(changed_subsection, 'changed')
      end  
  end
  
  def clauses_text_show(changed_subsection, action)
       "<table><tr><td class='rev_title_2'>Clauses #{action}:</td></tr></table>".html_safe
  end
 
#non prelim
#text of clause titles deleted or added
 def altered_clause_text(clause_title, selected_revision, current_project)   
 
    last_clause_change = Change.where('project_id = ? AND clause_id = ? AND clause_add_delete =?', current_project.id, clause_title.id, 2).last
    if selected_revision.id == last_clause_change[:revision_id]
      "<table width='100%'><tr id='#{clause_title.id.to_s}'class='clause_title_2'><td class='rev_clause_code'>#{clause_title.clauseref.subsection.section.ref.to_s}#{clause_title.clauseref.subsection.ref.to_s}.#{clause_title.clauseref.clausetype_id.to_s}#{clause_title.clauseref.clause.to_s}#{clause_title.clauseref.subclause.to_s}</td><td class ='rev_clause_title'> #{clause_title.clausetitle.text.to_s}</td><td class='padding'></td><td class='specline_link'>#{reinstate_original_clause(clause_title)}#{change_info_clause(clause_title)}</td></tr></table>".html_safe   
    else
      "<table width='100%'><tr id='#{clause_title.id.to_s}'class='clause_title_2'><td class='rev_clause_code'>#{clause_title.clauseref.subsection.section.ref.to_s}#{clause_title.clauseref.subsection.ref.to_s}.#{clause_title.clauseref.clausetype_id.to_s}#{clause_title.clauseref.clause.to_s}#{clause_title.clauseref.subclause.to_s}</td><td class ='rev_clause_title'> #{clause_title.clausetitle.text.to_s}</td><td class='padding'></td><td class='specline_link'></td></tr></table>".html_safe    
    end
 end


#prelim and non prelim
#set up annotation for altered line      
 def clause_line_text_altered(changed_clause, action)

    @altered_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id = ? AND event = ? AND linetype_id > ?', @current_project.id, changed_clause.id, @selected_revision.id, action, 2).order('specline_id')
    if !@altered_lines.blank?        
      check_added_print_status = @altered_lines.collect{|item| item.print_change}.uniq
      if check_added_print_status.include?(true) 
        "<table><tr id='#{changed_clause.id.to_s}'><td class='rev_subtitle'>Text #{action}:</td></tr></table>".html_safe
      else
          "<table><tr id='#{changed_clause.id.to_s}'><td class='rev_subtitle_strike'>Text #{action}:</td></tr></table>".html_safe
      end
    end
 end

 
 ####line formatting & links/actions 
  def original_line_text(line)
      
    if line.print_change == true
      rev_line_class = 'rev_row' 
    else
      rev_line_class = 'rev_row_strike'
    end
    
    last_clause_change = Change.where(:specline_id => line.specline_id).last
    if line[:id] == last_clause_change[:id] 
      "<table width='100%'><tr id='#{line.id.to_s}' class='#{rev_line_class}'><td class='rev_row_padding'>#{line_content(line)}</td><td class='padding'></td><td class='specline_link'>#{reinstate_original_line(line)}#{change_info(line)}</td></tr></table>".html_safe    
    else
      "<table width='100%'><tr id='#{line.id.to_s}' class='#{rev_line_class}'><td class='rev_row_padding'>#{line_content(line)}</td><td class='padding'></td><td class='specline_link'>#{change_info(line)}</td></tr></table>".html_safe        
    end    
  end
   

  def changed_line_text(changed_line, selected_revision, current_project) 
  
    if changed_line.print_change == true
      
      rev_row_class = 'rev_row'
      change_title_class = 'change_title'
      change_line_class = 'change_line' 
    else
      rev_row_class = 'rev_row_strike'
      change_title_class = 'change_title_strike'
      change_line_class = 'change_line_strike'
    end
       
    subsequent_changes = Change.where('id > ? AND specline_id = ?', changed_line.id, changed_line.specline_id)
    array_subsequent_changes = subsequent_changes.collect{|item| item.id}
    subsequent_change = array_subsequent_changes[0]
 
    if subsequent_changes.blank?
      current_line = Specline.find(changed_line.specline_id)
    else
      current_line = Change.find(subsequent_change)    
    end

    last_clause_change = Change.where(:specline_id => changed_line.specline_id).last
    if changed_line[:id] == last_clause_change[:id]   
      "<table width='100%'><tr id='#{changed_line.id.to_s}' class='#{rev_row_class}'><td class='rev_row_padding'>        <table width='100%'><tr><td class='#{change_title_class}'>From:</td></tr><tr><td class='#{change_line_class}'>#{line_content(changed_line)}</td></tr><tr><td class='#{change_title_class}'>To:</td></tr><tr><td class='#{change_line_class}'>#{line_content(current_line)}</td></tr></table>       <td class='padding'></td><td class='specline_link'>#{reinstate_original_line(changed_line)}#{change_info(changed_line)}#{toggle_print_setting(changed_line, selected_revision, current_project)}</td></tr></table>".html_safe
    else  
      "<table width='100%'><tr id='#{changed_line.id.to_s}' class='#{rev_row_class}'><td class='rev_row_padding'>        <table width='100%'><tr><td class='#{change_title_class}'>From:</td></tr><tr><td class='#{change_line_class}'>#{line_content(changed_line)}</td></tr><tr><td class='#{change_title_class}'>To:</td></tr><tr><td class='#{change_line_class}'>#{line_content(current_line)}</td></tr></table>       <td class='padding'></td><td class='specline_link'>#{change_info(changed_line)}#{toggle_print_setting(changed_line, selected_revision, current_project)}</td></tr></table>".html_safe
    end    
  end

  
  def line_content(line) 
    
      case line.linetype_id
        when 3 ; "#{line.txt4.text}: #{line.txt5.text}".html_safe
        when 4 ; "#{line.txt4.text}".html_safe 
        when 5 ; "<table><tr><td>#{line.txt3.text}:</td><td width = '5'></td><td>#{line.txt6.text}</td></tr></table>".html_safe
        when 6 ; "<table><tr><td>#{line.txt3.text}:</td><td width = '5'></td><td>#{line.txt5.text}</td></tr></table>".html_safe
        when 7 ; "#{line.txt4.text}".html_safe
        when 8 ; "#{line.txt4.text}: #{line.txt5.text}".html_safe
    end  
  end


  def reinstate_original_line(line)
    #if
    link_to image_tag("reinstate.png", :mouseover =>"reinstate_rollover.png", :border=>0), {:controller => "changes", :action => "reinstate", :id => line.id, :project_id => line.project_id}, :class => "get", :title => "reinstate"
    #end
  end
  
  def reinstate_original_clause(clause)
    #if
    link_to image_tag("reinstate.png", :mouseover =>"reinstate_rollover.png", :border=>0), {:controller => "changes", :action => "reinstate_clause", :id => clause.id, :project_id => @current_project.id, :revision_id => @selected_revision.id}, :class => "get", :title => "reinstate"
    #end
  end
  
  
  def toggle_print_setting(line, selected_revision, current_project)
    check_current_revision = Revision.where('project_id =?', current_project.id).last
    if  selected_revision.id == check_current_revision.id
      link_to image_tag("b_print.png", :mouseover =>"b_print_rollover.png", :border=>0), {:action => "print_setting", :id => line.id}, :class => "put", :title => "print option"
    end
  end
  
  def change_info(line)
    link_to image_tag("info.png", :mouseover =>"info_rollover.png", :border=>0), {:controller => "revisions", :action => "line_change_info", :id => line.id}, :class => "get", :title => "change info"
  end
  
  def change_info_clause(clause)
    link_to image_tag("info.png", :mouseover =>"info_rollover.png", :border=>0), {:controller => "revisions", :action => "clause_change_info", :id => @current_project, :rev_id => @selected_revision, :clause_id => clause.id}, :class => "get", :title => "change info"
  end

  def revision_help(revision_subsections, selected_revision, current_project)
    if revision_subsections.blank?
      if current_project.project_status == 'Draft'
        render :partial => "revision_help_draft"
      else
        current_revision_check = Revision.select('id, rev, date').where('project_id = ?', current_project.id).last
        if current_revision_check.date == nil
          if selected_revision.rev == '-'
            "<div id='edit_box_full'><div id='revision_help_text'><p>This is the original document before any revisions.</p></div></div>".html_safe
          else
            "<div id='edit_box_full'><div id='revision_help_text'><p>No changes have been made to the document since it was last published.</p></div></div>".html_safe
          end
        else
          "<div id='edit_box_full'><div id='revision_help_text'><p>Changes to the document are only recorded after document has been published for the first time.</p></div></div>".html_safe
        end
      end   
    end
  end
  
end