module ApplicationHelper

  def check_current_web(controller)
    if request.path_parameters[:controller] == controller
      return 'current_link'
    else
      return 'not_link'        
    end
  end


  def check_current(item)

    if item == 'project'
      if request.path_parameters[:controller] == 'projects'
        if request.path_parameters[:action] === 'manage_subsections'
          return 'not_link'
        else
          return 'current_link'          
        end       
      else
        return 'not_link'                              
      end
    end

    if item == 'document'
      if request.path_parameters[:controller] == 'projects'
        if request.path_parameters[:action] === 'manage_subsections'
          return 'current_link'
        else
          return 'not_link'          
        end 
      else
        return 'not_link'                              
      end
    end

    if item == 'revision'
      if request.path_parameters[:controller] == 'revisions'
        return 'current_link'
      else
        return 'not_link'                
      end
    end
    
    if item == 'publish'
      if request.path_parameters[:controller] == 'prints'
        return 'current_link'
      else
        return 'not_link'                
      end
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
  
  
end