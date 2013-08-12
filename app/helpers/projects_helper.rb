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
    specline_table(specline)
  end
end

end
