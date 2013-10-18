module ProjectsHelper


#establishes the identity of each edit_box tab
#def class_and_href_ref(clausetype_id, current_clausetype_id)
  
#  if clausetype_id == current_clausetype_id
#  "class='selected' href='##{clausetype_id}edit_view'".html_safe
  #"class='selected' #{link_to '', {:controller => "projects", :action => "show_tab_content", :id =>current_project_id, :subsection_id => subsection_id, :clausetype => clausetype_id}, :remote => true}".html_safe
#  else
#  "href='##{clausetype_id}edit_view'".html_safe
#  end
  
#end

#list of clausetypes to generate tabs of edit_box
#def clausetypes
#    clausetypes = Clausetype.all
#end



#switch statement to generate contents of each line depending on linetype_id
#def clausetype_filter(specline, clausetype, selected)
  
##next line has been altered
#  if clausetype == selected
#    specline_table(specline)
#  end
#end

#def guidance_link(current_project_id, subsection_id)
# check_guide = Subsection.where(:id => subsection_id).first
#  if !check_guide.guidepdf_id.nil?
#    "<div class='guide_download_button'>#{link_to 'guidance notes', {:controller => 'guidepdfs', :action => 'download', :id => check_guide.guidepdf_id}}</div>".html_safe
#  end
#end

def clause_link(current_project_id, subsection_id)
    "<div class='guide_download_button'>#{link_to 'add/delete clauses', {:controller => "speclines", :action => "manage_clauses", :id =>current_project_id, :project_id =>current_project_id, :subsection_id => subsection_id}}</div>".html_safe
end

end
