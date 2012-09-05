# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  #before_filter :prepare_for_mobile  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  helper_method :current_user  
    
  

protected

def current_project_and_templates(project_id, company_id)
    
    @projects = Project.where("company_id =?", company_id).order("code")
    project_templates = Project.where("id != ? AND company_id =?", project_id, company_id).order("code")
    if company_id != 1
      master_templates = Project.where("company_id =?", 1)
      @project_templates =  project_templates + master_templates
    else
      admin_templates = Project.where("company_id =?", 2)
      @project_templates =  project_templates + admin_templates
    end
    @current_project_template = Project.find(@current_project.parent_id)  
end

def current_revision_render(current_project)

    @all_project_revisions = Revision.where('project_id = ?', current_project.id).order('created_at')    
    last_revision = @all_project_revisions.last 
    
    project_revision_array = @all_project_revisions.collect{|i| i.id}
    project_revision_array.delete(project_revision_array.last)
    @used_revision_id_array = project_revision_array  

    last_rev_check = Change.where(:project_id => current_project.id, :revision_id => last_revision.id).first
    if last_rev_check
      @project_revisions = Revision.where('project_id = ?', current_project.id)        
    else
      @project_revisions = Revision.where(:id => @used_revision_id_array) 
    end
    @last_project_revision = @project_revisions.last
    
    if @last_project_revision
      if @last_project_revision.rev == '-'
        @current_revision_rev = '-'
      else
        if last_rev_check
          @current_revision_rev = @last_project_revision.rev.capitalize
        else
          current_revision = @project_revisions.last
          @current_revision_rev = current_revision.rev.capitalize
        end
      end
    else
      @current_revision_rev = 'n/a'
    end

end


def update_subsequent_specline_clause_line_ref(subsequent_specline_lines, action_type, selected_specline)
    
    if !subsequent_specline_lines.blank? 
     #temp_specline_ref = []
     subsequent_specline_lines.each_with_index do |subsequent_specline, i|
      if action_type == 'new'
        subsequent_specline.update_attributes(:clause_line => selected_specline.clause_line + 2 + i)
      end
      if action_type =='delete'
        subsequent_specline.update_attributes(:clause_line => selected_specline.clause_line + i)
      end
     end
    end    
end
  
  def record_delete
    #do not record change if project status is set to draft    
    rev_status_check = Revision.where(:project_id => @specline.project_id).order('created_at').last
    if rev_status_check.rev.to_s >= 'a'

        
     current_revision = Revision.where('project_id =?', @specline.project_id).last
      if !current_revision.blank?
      
        existing_change_record = Change.where('specline_id =? AND revision_id =?', @specline.id, current_revision.id).first
        if existing_change_record.blank?
        #split this into a private method to DRY up code in controller  
          if @clause_change_record.blank?
             clause_add_delete = 1
          else
             clause_add_delete = @clause_change_record
          end
                               
          new_delete_rec = Change.new do |n|        
            n.clause_add_delete = clause_add_delete
            n.event = 'deleted'
            n.revision_id = current_revision.id
            n.project_id = @specline.project_id
            n.clause_id = @specline.clause_id
            n.specline_id = @specline.id
            n.linetype_id = @specline.linetype_id
            n.txt3_id = @specline.txt3_id
            n.txt4_id = @specline.txt4_id
            n.txt5_id = @specline.txt5_id
            n.txt6_id = @specline.txt6_id
            n.user_id = current_user.id
          end
          new_delete_rec.save
  
        else
          if existing_change_record.event == 'new'
            existing_change_record.destroy
          else
            existing_change_record.event = 'deleted'
            existing_change_record.save
          end
        end
      end
    end   
  end
    
  def record_new
   #do not record change if project status is set to draft
    rev_status_check = Revision.where('project_id =?', @new_specline.project_id).order('created_at').last
    if rev_status_check.rev.to_s >= 'a'

    current_revision = Revision.where(:project_id => @new_specline.project_id).last
      if !current_revision.blank?
      existing_delete_record = Change.where(:project_id => @new_specline.project_id, :linetype_id => @new_specline.linetype_id, :clause_id => @new_specline.clause_id, :txt3_id => @new_specline.txt3_id, :txt4_id => @new_specline.txt4_id, :txt5_id => @new_specline.txt5_id, :txt6_id => @new_specline.txt6_id, :event => 'deleted', :revision_id => current_revision.id).first
        if existing_delete_record.blank?  
          if @clause_change_record.blank?
             @clause_add_delete = 1
          else
             @clause_add_delete = @clause_change_record
          end                    
          new_new_rec = Change.new do |n|        
            n.clause_add_delete = @clause_add_delete
            n.event = 'new'
            n.revision_id = current_revision.id
            n.project_id = @new_specline.project_id
            n.clause_id = @new_specline.clause_id
            n.specline_id = @new_specline.id
            n.linetype_id = @new_specline.linetype_id
            n.txt3_id = @new_specline.txt3_id
            n.txt4_id = @new_specline.txt4_id
            n.txt5_id = @new_specline.txt5_id
            n.txt6_id = @new_specline.txt6_id
            n.user_id = current_user.id
          end
          new_new_rec.save
        else
          prior_specline_changes = Change.where('specline_id =?', existing_delete_record.specline_id)
          prior_specline_changes.each do |prior_change|
            prior_change.specline_id = @new_specline.id
            prior_change.save
          end
          existing_delete_record.destroy
        end   
      end
    end
  end

  
  def record_change
    rev_status_check = Revision.where(:project_id => @specline.project_id).order('created_at').last
    if rev_status_check.rev.to_s >= 'a'
  
      current_revision = Revision.where('project_id =?', @specline.project_id).last

      existing_change_record = Change.where('specline_id =? AND revision_id =?', @specline.id, current_revision.id).first
      if existing_change_record #if change record does exist for given specline_line then...  
        check_new_match_previous = Change.where(:revision_id => current_revision.id, :specline_id => @specline.id, :clause_id => @specline_update.clause_id, :linetype_id => @specline_update.linetype_id, :txt3_id => @specline_update.txt3_id, :txt4_id => @specline_update.txt4_id, :txt5_id => @specline_update.txt5_id, :txt6_id => @specline_update.txt6_id).first
        if check_new_match_previous
          existing_change_record.destroy        
        else
          if existing_change_record.event == 'new'
            existing_delete_record = Change.where(:project_id => @specline_update.project_id, :linetype_id => @specline_update.linetype_id, :clause_id => @specline_update.clause_id, :txt3_id => @specline_update.txt3_id, :txt4_id => @specline_update.txt4_id, :txt5_id => @specline_update.txt5_id, :txt6_id => @specline_update.txt6_id, :event => 'deleted', :revision_id => current_revision.id).first
            if existing_delete_record.blank?
              existing_change_record.linetype_id = @specline_update.linetype_id
              existing_change_record.txt3_id = @specline_update.txt3_id
              existing_change_record.txt4_id = @specline_update.txt4_id
              existing_change_record.txt5_id = @specline_update.txt5_id
              existing_change_record.txt6_id = @specline_update.txt6_id
              existing_change_record.user_id = current_user.id
              existing_change_record.save
            else
              existing_delete_record.destroy
              existing_change_record.destroy               
            end
          end
        end                        
      else
      @specline = Specline.find(params[:id])
        new_change_rec = Change.new do |n|
          n.event = 'changed'
          n.revision_id = current_revision.id
          n.project_id = @specline.project_id
          n.clause_id = @specline.clause_id
          n.specline_id = @specline.id
          n.linetype_id = @specline.linetype_id
          n.txt3_id = @specline.txt3_id
          n.txt4_id = @specline.txt4_id
          n.txt5_id = @specline.txt5_id
          n.txt6_id = @specline.txt6_id
          n.user_id = current_user.id
        end
        new_change_rec.save
      end              
    end  
  end

    
def txt1_insert_line(specline, previous_specline, subsequent_specline_lines)
  check_linetype = Linetype.find(previous_specline.linetype_id)
  if check_linetype.txt1 == true
    specline.txt1_id = previous_specline.txt1_id + 1
    specline.save
   #subsequent_clause_lines = Specline.where("project_id = ? AND clause_id = ? AND clause_line > ?", specline.project_id, specline.clause_id, specline.clause_line).order("clause_line")
    
   if subsequent_specline_lines.count == 1
     update_subsequent_lines_last(subsequent_specline_lines, specline.txt1_id)    
   else
    update_subsequent_lines(subsequent_specline_lines, specline.txt1_id)
  end
  end
end

                                                                                                                                           
def txt1_delete_line(specline) 
  check_linetype = Linetype.find(specline.linetype_id)
  #if check_linetype.txt1 == true
    get_previous_specline_line = Specline.where("project_id = ? AND clause_id = ? AND clause_line < ?", specline.project_id, specline.clause_id, specline.clause_line).order("clause_line").last
    check_linetype = Linetype.find(get_previous_specline_line.linetype_id)
      if check_linetype.txt1 == true
        set_txt1_id = get_previous_specline_line.txt1_id
      else
        set_txt1_id = 0
      end  
    subsequent_clause_lines = Specline.where("project_id = ? AND clause_id = ? AND clause_line > ?", specline.project_id, specline.clause_id, specline.clause_line).order("clause_line")
    update_subsequent_lines(subsequent_clause_lines, set_txt1_id)
  #end
end


def txt1_change_linetype(specline, old_linetype, new_linetype)

  if old_linetype.txt1 == true
    if new_linetype.txt1 == false
      specline.txt1_id = 1
      specline.save
      set_txt1_id = 0
    end
  else
    if new_linetype.txt1 == true	 
      get_previous_specline_line = Specline.where("project_id = ? AND clause_id = ? AND clause_line < ?", specline.project_id, specline.clause_id, specline.clause_line).last
      check_linetype = Linetype.find(get_previous_specline_line.linetype_id)
      if check_linetype.txt1 == true
        specline.txt1_id = get_previous_specline_line.txt1_id + 1
        set_txt1_id = get_previous_specline_line.txt1_id + 1
      else
        specline.txt1_id = 1
        set_txt1_id = 1
      end                                        
      specline.save  
    end
  end
  subsequent_clause_lines = Specline.where("project_id = ? AND clause_id = ? AND clause_line > ?", specline.project_id, specline.clause_id, specline.clause_line).order('clause_line')
  update_subsequent_lines(subsequent_clause_lines, set_txt1_id)  
end


def update_subsequent_lines(subsequent_clause_lines, set_txt1_id)
  @subsequent_prefixes = []
  subsequent_clause_lines.each_with_index do |next_clause_line, i|

  check_linetype = Linetype.where('id =?', next_clause_line.linetype_id).first
    if check_linetype.txt1 == true
      next_txt1_id = (set_txt1_id + 1 + i)
      next_clause_line.txt1_id = next_txt1_id
      next_clause_line.save      
      next_txt1_text = Txt1.where(:id => next_txt1_id).first
      @subsequent_prefixes[i] = [next_clause_line.id, next_txt1_text.text] 
    else
      break
    end
  end
end



def update_subsequent_lines_last(subsequent_clause_lines, set_txt1_id)
  subsequent_clause_lines.each_with_index do |next_clause_line, i|
  check_linetype = Linetype.where('id =?', next_clause_line.linetype_id).first
    if check_linetype.txt1 == true
      next_clause_line.txt1_id = (set_txt1_id + i)
      next_clause_line.save
    else
      break
    end
  end
end

def update_subsequent_lines_on_move(subsequent_clause_lines, set_txt1_id)
    @subsequent_prefixes = []
  subsequent_clause_lines.each_with_index do |next_clause_line, i|
  check_linetype = Linetype.where('id =?', next_clause_line.linetype_id).first
    if check_linetype.txt1 == true
       next_txt1_id = (set_txt1_id + 1 + i)
      next_clause_line.txt1_id = next_txt1_id
      next_clause_line.save      
      next_txt1_text = Txt1.where(:id => next_txt1_id).first     
      @subsequent_prefixes[i] = [next_clause_line.id, next_txt1_text.text] 
    else
      break
    end
  end
end




    
private

def authentize_user
  @current_user ||= User.find(session[:user_id]) if session[:user_id]
  if @current_user.role == 'user'
       redirect_to log_out_path
  end
end

  def require_user
    unless current_user
      redirect_to log_out_path
      return false
    end
  end


  def current_user  
    @current_user ||= User.find(session[:user_id]) if session[:user_id]  
  end 
  
  def mobile_device?  
    if session[:mobile_param]  
      session[:mobile_param] == "1"  
    else  
      request.user_agent =~ /Mobile|webOS/  
    end  
  end  
  helper_method :mobile_device?
  
def prepare_for_mobile  
  session[:mobile_param] = params[:mobile] if params[:mobile]  
  request.format = :mobile if mobile_device?  
end

  def mobile_redirect
    if mobile_device?
    redirect_to mob_new_session_path
    end
  end   
end
