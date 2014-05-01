module ApplicationHelper

  def check_current_web(controller)
    if request.path_parameters[:controller] == controller
      return 'current_link'
    else
      return 'not_link'        
    end
  end


  def check_current(item)

    controller = request.path_parameters[:controller]
    action = request.path_parameters[:action]

    if controller == 'projects'
      if ['index', 'new', 'edit'].include?(action)
        check = 'project'
      else
        check = 'document'
      end
    end

    if controller == 'speclines'
        check = 'document'
    end
    
    if controller == 'clauses'
        check = 'document'
    end
    
    if controller == 'revisions'
        check = 'revision'
    end    

    if controller == 'prints'
        check = 'publish'
    end

    if check == item
      return 'current_link'
    else
      return 'not_link'          
    end       
  end

  
  def check_current_topic(topic)
    if request.parameters[:topic].blank? && topic == 'all'
        return 'current_topic'    
    end
    if request.parameters[:topic] == topic
        return 'current_topic'
    else
        return 'not_topic'    
    end
  end

  def error_check(company, field)
       if !company.errors[field].blank?
       "<t style='color: #ff0000'>#{company.errors[field][0]}</t>".html_safe
      end       
  end
  
  def label_error_check(model, label_field, label_text)
          if !model.errors[label_field].blank?    
        "<t style='color: #ff0000'>#{label_text}:</t>".html_safe
      else
        "#{label_text}:".html_safe
      end
  end
  
  def show_image(photo, height)
    if photo.photo_file_name
      image_tag (photo.photo.url), :height=> height
    else
      "No image has been uploaded".html_safe
    end
  end
  

##specling table formatting
def specline_table(specline)
  @line = specline
    
    case specline.linetype_id
      #clause title
      when 1, 2 ; "<table id='#{specline.id}' class='specline_table' width='100%'><tr class='specline_row'><td class='edit_clause_code'>#{clause_ref_text(specline)}</td><td class='edit_clause_title'>#{specline.clause.clausetitle.text}</td><td class='suffixed_line_menu_mob'>#{specline_mob_clause_menu(specline)}</td><td class='suffixed_line_menu' width ='120'>#{specline_line_new_link(specline)}#{clause_new_link(specline)}#{clause_delete_link(specline)}#{clause_help_link(specline)}</td></tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=2 >#{specline_suffix_menu_mob_clause(specline)}</td></tr></table>".html_safe
      #prefixed - editable text    
      when 3 ; "#{html_prefix(specline)}  <td width='10px'></td><td class='text_prefix' width='18'>#{specline.txt1.text}.</td><td class='text_text'><span id='#{specline.id}' class='editable_text4'>#{specline.txt4.text}</span>: <span id='#{specline.id}'class='editable_text5'>#{specline.txt5.text}</span></td>   <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=4 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe
      #prefixed - editable text: editable text
      when 4 ; "#{html_prefix(specline)}  <td width='10px'></td><td class='text_prefix' width='18'>#{specline.txt1.text}.</td><td class='text_text'><span id='#{specline.id}'class='editable_text4'>#{specline.txt4.text}</span></td>    <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=4 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe
      #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
      when 5 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td><table><tr><td class='text_text'><span id='#{specline.id}'class='editable_text3'>#{specline.txt3.text}</span></td><td>:</td><td width = '5'></td><td><span id='#{specline.id}'class='editable_text6'>#{specline.txt6.text}</span></td></tr></table></td>   <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe
      #
      when 6 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td><table><tr><td class='text_text'><span id='#{specline.id}'class='editable_text3'>#{specline.txt3.text}</span></td><td>:</td><td width = '5'></td><td><span id='#{specline.id}'class='editable_text5'>#{specline.txt5.text}</span></td></tr></table></td>   <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe
      #editable text
      when 7 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td class='text_text'><span id='#{specline.id}'class='editable_text4'>#{specline.txt4.text}</span></td>    <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe
      #editable text: editable text                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
      when 8 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td class='text_text'><span id='#{specline.id}'class='editable_text4'>#{specline.txt4.text}</span>: <span id='#{specline.id}'class='editable_text5'>#{specline.txt5.text}</span></td>   <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe
      #product identity pair text
      when 10 ; "#{html_data_prefix(specline)}  <td class='prefix' width='10px'>-</td> #{identity_pair(specline)} <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe   
      #product peform pair text
      when 11 ; "#{html_data_prefix(specline)}  <td class='prefix' width='10px'>-</td> #{perform_pair(specline)} <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe
      #cross reference
      when 12 ; "#{html_xref_prefix(specline)}  <td class='prefix' width='10px'>-</td>   <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td><td class='text_text'><span id='#{specline.id}' class='editable_text4'>#{specline.txt4.text}</span>: <span id='#{specline.id}'class='editable_xref'>#{specline.txt5.text}</span></td></tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe   
      #product information (not linked to product database)
#     when 13 ; "#{html_prefix(specline)}  <td class='prefix' width='10px'>-</td><td class='text_text'><span id='#{specline.id}'class='editable_text4'>#{specline.txt4.text}</span>: <span id='#{specline.id}'class='editable_text5'>#{specline.txt5.text}</span></td>   <td class='suffixed_line_menu_mob'>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe

    end
end




def html_prefix(specline)
    "<table id='#{specline.id}' class='specline_table' width='100%'><tr class='specline_row'><td class='prefixed_line_space'></td><td class='prefixed_line_menu'>#{specline_move}</td>".html_safe
end

def html_data_prefix(specline)
    "<table id='#{specline.id}' class='specline_table' width='100%'><tr class='specline_data_row'><td class='prefixed_line_space'></td><td class='prefixed_line_menu'></td>".html_safe
end

def html_xref_prefix(specline)
    "<table id='#{specline.id}' class='specline_table' width='100%'><tr class='specline_xref_row'><td class='prefixed_line_space'></td><td class='prefixed_line_menu'>#{specline_move}</td>".html_safe
end

def html_suffix(specline)
  "<td class='suffixed_line_menu_mob>#{specline_mob_spec_menu(specline)}</td>#{specline_links(specline)}</tr><tr class='specline_mob_menu_popup'><td class='mob_line_menu' colspan=3 >#{specline_suffix_menu_mob_spec(specline)}</td></tr></table>".html_safe
end

def identity_pair(specline)
  if specline.identity.identkey.text == "Manufacturer"
  "<td class='data_key'><span id='#{specline.id}'class='editable_product_key'>#{specline.identity.identkey.text}</span>: <span id='#{specline.id}'class='editable_product_value'>#{specline.identity.identvalue.company.company_address}</span></td>".html_safe
  else
  "<td class='data_key'><span id='#{specline.id}'class='editable_product_key'>#{specline.identity.identkey.text}</span>: <span id='#{specline.id}'class='editable_product_value'>#{specline.identity.identvalue.identtxt.text}</span></td>".html_safe  
  end
end

def perform_pair(specline)  
  
#  perform_key = Txt3.includes(:preforms).where('performs.id' => specline.txt6_id).first
#  key_text_string = perform_key.text 
#  
#  performance_values = Performtxt6unit.includes(:txt6units => [:txt6s, :units, :standards]).where(:performance_id => specline.txt6_id)   
#    last_value = performance_values.pop    
#    if !performance_values.empty?   
#      value_text_string = performance_values.collect{|i| '#{i.txt6unit.txt6.text}'}.joins(',')    
#      value_text_string << ' & '<< last_value.txt6unit.txt6.text
#    else
#      value_text_string << last_value.txt6unit.txt6.text
#    end
#    if value.txt6unit.unit_id
#      value_text_string << ' '<< value.txt6unit.unit.text
#    end         
#    if value.txt6unit.standard_id
#      value_text_string << ' to '<< value.txt6unit.standard.text
#    end      
#  end  
  "<td class='text_text'><span id='#{specline.id}'class='editable_product_key'>#{specline.perform.performkey.text}</span>: <span id='#{specline.id}'class='editable_product_value'>#{specline.perform.performvalue.full_perform_value}</span></td>".html_safe
end


def specline_move
  image_tag("move.png", :mouseover =>"move_rollover.png", :border=>0, :title => 'drag & drop')
end

def specline_mob_spec_menu(specline)
  image_tag("menu.png", :mouseover =>"menu_rollover.png", :border=>0, :title => 'click for menu')  
end

def specline_mob_clause_menu(specline)
  image_tag("menu.png", :mouseover =>"menu_rollover.png", :border=>0, :title => 'click for menu')   
end

def specline_links(specline)
   "<td class='suffixed_line_menu'>#{specline_line_new_link(specline)}#{specline_line_edit_link(specline)}#{specline_line_delete_link(specline)}#{clause_manufact_link(specline)}  </td>".html_safe
end

def specline_suffix_menu_mob_clause(specline) 
   "#{clause_help_link(specline)}#{clause_delete_link(specline)}#{clause_new_link(specline)}#{specline_line_new_link(specline)}".html_safe 
end

def specline_suffix_menu_mob_spec(specline) 
   "#{clause_manufact_link(specline)}#{specline_line_delete_link(specline)}#{specline_line_edit_link(specline)}#{specline_line_new_link(specline)}".html_safe 
end


def clause_ref_text(specline)                                                        
  specline.clause.clauseref.subsection.section.ref + sprintf("%02d", specline.clause.clauseref.subsection.ref).to_s<<"."<<specline.clause.clauseref.clausetype_id.to_s<<sprintf("%02d", specline.clause.clauseref.clause).to_s<<specline.clause.clauseref.subclause.to_s 
end

def clause_new_link(specline)
  link_to image_tag("new_clause.png", :mouseover =>"new_clause_rollover.png", :border=>0), {:controller => "speclines", :action => "manage_clauses", :id => specline.project_id, :project_id => specline.project_id, :subsection_id => specline.clause.clauseref.subsection_id}, :title => "add/delete clauses"
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




def clause_manufact_link(specline)
end












  
end