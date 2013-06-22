module UsersHelper


  def  created(licence)
    licence.user.created_at.strftime("%e %B %Y")
  end
  
  def licence_status(licences_used, no_licences)
    spare_licences = no_licences - licences_used
    if spare_licences > 0 
      "#{licences_used} licence(s) are currently active out of an available #{no_licences} licence(s)".html_safe
    else
      "<span style='color: #ff0000'>All the company's licences (#{no_licences}) are allocated</span>".html_safe
    end
  end
  
  
  def  check_active(licence)
  
  check_user_role = User.where('id =?', licence.user_id).first
    if check_user_role.role == 'admin'
      if licence.active_licence == 0 
        "<div class='small_green_button'>#{activate(licence)}</div> <div class='small_red_button' style='display: none;'>#{deactivate(licence)}</div>".html_safe
      else
        "<div class='small_red_button'>#{deactivate(licence)}</div> <div class='small_green_button' style='display: none;'>#{activate(licence)}</div>".html_safe
      end
    end
  end
  
  
  def  last_seen(licence)
    if !licence.last_sign_in.blank?   
      licence.last_sign_in.strftime("%e %B %Y")
    else
      "n/a"
    end
  end
  
  def  locked_at(licence)

    #if licence.locked_at == 1
      "<div class='small_green_button'>#{remove_unlock(licence)}</div>".html_safe   
    #end
  end

  def deactivate(licence)
    link_to 'active', {:controller=> "users", :action => "update_licence_status", :id => licence.user_id}, :class => "get"
  end

  def activate(licence)
    link_to 'inactive', {:controller=> "users", :action => "update_licence_status", :id => licence.user_id}, :class => "get"
  end
  
  def remove_unlock(licence)
    link_to 'un-lock', {:controller=> "users", :action => "unlock_user", :id => licence.user_id}, :class => "get"
  end
  
end
