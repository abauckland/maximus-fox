module UsersHelper


  def  created(licence)
    licence.user.created_at.strftime("%e %B %Y")
  end
  
  def number_times_logged_in(licence)
   licence.number_times_logged_in  
  end
  
  def licence_status(licences_used, no_licences)
    spare_licences = no_licences - licences_used
    if spare_licences > 0 
      "<div id='information'>#{licences_used} licence(s) are currently active out of an available #{no_licences} licence(s)</div>".html_safe
    else
      "<div id='information' style='color: #ff0000'>All the company's licences (#{no_licences}) are allocated</div>".html_safe
    end
  end
  
  
  def  check_active(licence)
  
  check_user_role = User.where('id =?', licence.user_id).first
    if check_user_role.role != 'admin'
      if licence.active_licence == 0 
        "<div id='#{licence.user_id}'><div id='active_button'>#{activate(licence)}</div><div id='deactive_button' style='display: none;'>#{deactivate(licence)}</div></div>".html_safe
      else
        "<div id='#{licence.user_id}'><div id='deactive_button'>#{deactivate(licence)}</div><div id='active_button' style='display: none;'>#{activate(licence)}</div></div>".html_safe
      end
    else     
      "<div id='#{licence.user_id}'></div>".html_safe
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

    if licence.locked_at == 1
      "<div id='unlock-#{licence.user_id}'><div id='unlock_button'>#{remove_unlock(licence)}</div></div>".html_safe   
    end
  end

  def deactivate(licence)
    link_to 'Active', {:controller=> "users", :action => "update_licence_status", :id => licence.user_id}, :class => "get"
  end

  def activate(licence)
    link_to 'Inactive', {:controller=> "users", :action => "update_licence_status", :id => licence.user_id}, :class => "get"
  end
  
  def remove_unlock(licence)
    link_to 'Locked', {:controller=> "users", :action => "unlock_user", :id => licence.user_id}, :class => "get"
  end

  def add_user(licences_used, no_licences, company_id)
    spare_licences = no_licences - licences_used
    if spare_licences > 0 
       render :partial => "new_user", :locals => { :user => @user, :company_id => company_id, :display => 'block' }
    else
      render :partial => "new_user", :locals => { :user => @user, :company_id => company_id, :display => 'none' }
    end
    
  end
  
end
