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

  def clean_text(value)
    @value = value 
    @value.strip
    @value.chomp
    @value.chomp   
    while [".", ",", ";", ":", "!", "?"].include?(value.last)
    @value.chop!
    end
  end


  def current_project_and_templates(project_id, company_id)
    
    @projects = Project.where("company_id =?", company_id).order("code")
    project_templates = Project.where("id != ? AND company_id =?", project_id, company_id).order("code")
    
    #allow main account view projects within admin account (company_id = 2)
    if company_id != 1
      master_templates = Project.where("company_id =?", 1)
      @project_templates =  project_templates + master_templates
    else
      admin_templates = Project.where("company_id =?", 2)
      @project_templates =  project_templates + admin_templates
    end
    
    #get curent template for project
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
    
    if subsequent_specline_lines   
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

     #get current revision for project   
     current_revision = Revision.where('project_id =?', @specline.project_id).last
      if current_revision
        #check if any changes already made for selected specline in current revision
        #check by specline_id and rev_id only as delete action does not create/change a line whereby it may match an existing line or previous change
        existing_change_record = Change.where('specline_id =? AND revision_id =?', @specline.id, current_revision.id).first
        if existing_change_record.blank?
          #define if change action applied to line, clause or section
          #information used when reporting changes and upon reinstatement
          if @clause_change_record.blank?
             clause_add_delete = 1
          else
             clause_add_delete = @clause_change_record
          end
          #if no previous changes for specline create delete record for line                     
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
          #where previous 'new' and 'change' events have been reorded
          #'delete' events not checked as none will exist for selected line (you cannot select a line that has already been deleted)
          #if a change has been previously made to selected specline then...
          if existing_change_record.event == 'new'
            #if previous change event was creation of new specline then destory change record
            existing_change_record.destroy
          end
          
          if existing_change_record.event == 'changed'
            #if previous change was for change to specline then amend action to 'delete' from 'change'
            existing_change_record.event = 'deleted'
            existing_change_record.user_id = current_user.id
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

    #get current revision for project  
    current_revision = Revision.where(:project_id => @new_specline.project_id).last
      if current_revision
                       
      #check if any changes already made for selected specline in current revision
      #check by rev_id, txts and linetype as 'new' line may match an existing line or previous change record
      #private method in application controller
      specline_current_text_match_check(@new_specline, current_revision)
      if @check_new_match_previous.blank?
          #define if change action applied to line, clause or section
          #information used when reporting changes and upon reinstatement          
          if @clause_change_record.blank?
             @clause_add_delete = 1
          else
             @clause_add_delete = @clause_change_record
          end                    
          #if no previous changes for specline create new record for line 
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
          #if previous action was 'delete'
          if @check_new_match_previous.event == 'deleted'
            #if a previous delete change record matches do not create 'new' change record
            #update specline_id of all precious changes for existing change record specline with specline of new line
            update_specline_id_prior_changes(@check_new_match_previous.specline_id, @new_specline.id)
            #delete change record, as this line has no longer been deleted, but re-created
            @check_new_match_previous.destroy      
          end
          
          if @check_new_match_previous.event == 'changed'
            #define if change action applied to line, clause or section
            #information used when reporting changes and upon reinstatement          
            if @clause_change_record.blank?
              @clause_add_delete = 1
            else
              @clause_add_delete = @clause_change_record
            end
            #update specline_id of all previous changes for existing change record specline with specline of new line  

            #if previous action was 'change'
            #create 'new' change record for current specline with id of old change
            @previous_changed_specline = Specline.where(:id => @check_new_match_previous.specline_id).first
            #update specline_id of all previous changes for existing change record specline with specline of new line
            update_specline_id_prior_changes(@check_new_match_previous.specline_id, @new_specline.id)
            
            new_new_rec = Change.new do |n|        
              n.clause_add_delete = @clause_add_delete
              n.event = 'new'
              n.revision_id = current_revision.id
              n.project_id = @check_new_match_previous.project_id
              n.clause_id = @check_new_match_previous.clause_id
              n.specline_id = @check_new_match_previous.specline_id
              n.linetype_id = @check_new_match_previous.linetype_id
              n.txt3_id = @previous_changed_specline.txt3_id
              n.txt4_id = @previous_changed_specline.txt4_id
              n.txt5_id = @previous_changed_specline.txt5_id
              n.txt6_id = @previous_changed_specline.txt6_id
              n.user_id = current_user.id
            end
            new_new_rec.save           

            #delete change record, as this line has no longer been changed, but re-created
            @check_new_match_previous.destroy                   
          end         
      end   
     end
   end
  end

  
  def record_change
    
   #do not record change if project status is set to draft
    rev_status_check = Revision.where('project_id =?', @specline.project_id).order('created_at').last
    if rev_status_check.rev.to_s >= 'a'

    #get current revision for project  
    current_revision = Revision.where('project_id =?', @specline.project_id).last
      if current_revision

      #check if any changes already made for selected specline in current revision
      #check by rev_id, txts and linetype as 'changed' line may match an existing line or previous change record
      #private method in application controller
      specline_current_text_match_check(@specline_update, current_revision)
      if @check_new_match_previous.blank?
        #check if any changes already made for selected specline in current revision
        #check by specline_id and rev_id only as delete action does not create/change a line whereby it may match an existing line or previous change
        existing_change_record = Change.where('specline_id =? AND revision_id =?', @specline.id, current_revision.id).first
        if existing_change_record.blank?          
          #changes can only be applied to line
          #information used when reporting changes and upon reinstatement          
          @clause_add_delete = 1

          #if no previous changes for specline create new record for line 
          @specline = Specline.find(params[:id])
          new_new_rec = Change.new do |n|        
            n.clause_add_delete = @clause_add_delete
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
          new_new_rec.save
        else
          #if previous action was 'new'
          if existing_change_record.event == 'new'
                existing_change_record.txt3_id = @specline_update.txt3_id
                existing_change_record.txt4_id = @specline_update.txt4_id
                existing_change_record.txt5_id = @specline_update.txt5_id
                existing_change_record.txt6_id = @specline_update.txt6_id
                existing_change_record.linetype_id = @specline_update.linetype_id
                existing_change_record.user_id = current_user.id
                existing_change_record.save                     
          end
          #if existing_change_record exists then do nothing because original chang record still valid         
        end
      else  
          #if previous action was 'delete'
          if @check_new_match_previous.event == 'deleted'
            
            previous_changes_for_specline = Change.where(:specline_id => @specline_update.id).first
            if previous_changes_for_specline
              if previous_changes_for_specline.event == 'new'
                #create temp variable containing specline_id of line being changed
                specline_id_new_delete_record = @check_new_match_previous.specline_id
            
                #update specline_id of all previous changes for existing change record specline with specline of new line
                update_specline_id_prior_changes(@check_new_match_previous.specline_id, @specline.id)
                #delete change record, as this line has no longer been changed, but re-created
                @check_new_match_previous.destroy
                previous_changes_for_specline.destroy      
              end
              if previous_changes_for_specline.event == 'changed'            
                #create temp variable containing specline_id of line being changed
                specline_id_new_delete_record = @check_new_match_previous.specline_id
                #update specline_id of all previous changes for existing change record specline with specline of new line
                update_specline_id_prior_changes(@check_new_match_previous.specline_id, @specline.id)
                            
                #changes can only be applied to line
                #information used when reporting changes and upon reinstatement          
                @clause_add_delete = 1 
            
                previous_changes_for_specline.event = 'deleted'
                previous_changes_for_specline.specline_id = specline_id_new_delete_record
                previous_changes_for_specline.user_id = current_user.id
                previous_changes_for_specline.save
                
                #delete change record, as this line has no longer been changed, but re-created
                @check_new_match_previous.destroy                           
              end
            else
                #create temp variable containing specline_id of line being changed
                specline_id_new_delete_record = @check_new_match_previous.specline_id
            
                #update specline_id of all previous changes for existing change record specline with specline of new line
                update_specline_id_prior_changes(@check_new_match_previous.specline_id, @specline.id)

                #changes can only be applied to line
                #information used when reporting changes and upon reinstatement          
                @clause_add_delete = 1 
            
                #create 'deleted' change record for current specline
                @specline = Specline.find(params[:id])
                new_deleted_rec = Change.new do |n|        
                  n.clause_add_delete = @clause_add_delete
                  n.event = 'deleted'
                  n.revision_id = current_revision.id
                  n.project_id = @specline.project_id
                  n.clause_id = @specline.clause_id
                  n.specline_id = @check_new_match_previous.specline_id           
                  n.linetype_id = @specline.linetype_id
                  n.txt3_id = @specline.txt3_id
                  n.txt4_id = @specline.txt4_id
                  n.txt5_id = @specline.txt5_id
                  n.txt6_id = @specline.txt6_id
                  n.user_id = current_user.id
                end
                new_deleted_rec.save  
                #delete change record, as this line has no longer been changed, but re-created
                @check_new_match_previous.destroy
             
            end
                       
          end          
          #if previous action was 'new' then update content of change record
          if @check_new_match_previous.event == 'new'
            previous_changes_for_specline = Change.where(:specline_id => @specline_update.id).first
            if previous_changes_for_specline      
              previous_changes_for_specline.linetype_id = @specline_update.linetype_id
              previous_changes_for_specline.txt3_id = @specline_update.txt3_id
              previous_changes_for_specline.txt4_id = @specline_update.txt4_id
              previous_changes_for_specline.txt5_id = @specline_update.txt5_id
              previous_changes_for_specline.txt6_id = @specline_update.txt6_id
              previous_changes_for_specline.user_id = current_user.id           
              previous_changes_for_specline.save                         
            else                 
#what happens here?         
            end
          end          
          #if previous action was 'changed' then line will have changed back to original
          if @check_new_match_previous.event == 'changed'              
            #double check is same specline as recorded change
            #this should be called when a prevsiously changed record is changed back to its original status
            if @check_new_match_previous.specline_id == @specline_update.id
               @check_new_match_previous.destroy              
            else

              previous_changes_for_specline = Change.where(:specline_id => @specline_update.id).first
              if previous_changes_for_specline.blank?

                #update specline_id of all previous changes for existing change record specline with specline of new changed line
                update_specline_id_prior_changes(@check_new_match_previous.specline_id, @specline.id)              
                            
                #changes can only be applied to line
                #information used when reporting changes and upon reinstatement          
                @clause_add_delete = 1 
            
                #create 'deleted' change record for current specline
                @specline = Specline.find(params[:id])
                previous_changes_for_specline = Change.new do |n|        
                  n.clause_add_delete = @clause_add_delete
                  n.event = 'changed'
                  n.revision_id = current_revision.id
                  n.project_id = @specline.project_id
                  n.clause_id = @specline.clause_id
                  n.specline_id = @check_new_match_previous.specline_id           
                  n.linetype_id = @specline.linetype_id
                  n.txt3_id = @specline.txt3_id
                  n.txt4_id = @specline.txt4_id
                  n.txt5_id = @specline.txt5_id
                  n.txt6_id = @specline.txt6_id
                  n.user_id = current_user.id
                end
                previous_changes_for_specline.save 
                           
                update_specline_id_prior_changes(previous_changes_for_specline.specline_id, @check_new_match_previous.specline_id)
              
                @check_new_match_previous.destroy                
              
              
              else
                #if current change line change record event = new  
                if previous_changes_for_specline.event == 'changed'
                  #update specline_id of all previous changes for existing change record specline with specline of new changed line
                  update_specline_id_prior_changes(@check_new_match_previous.specline_id, @specline.id)              

                  current_matched_specline = Specline.where(:id => @check_new_match_previous.specline_id).first
              
                  #update change record of selected line to reflect               
                  previous_changes_for_specline.specline_id = @check_new_match_previous.specline_id
                  previous_changes_for_specline.user_id = current_user.id
                  previous_changes_for_specline.save
                  #update specline_id of all previous changes for selected change record specline with specline of matched change line
                  update_specline_id_prior_changes(previous_changes_for_specline.specline_id, @check_new_match_previous.specline_id)
              
                  @check_new_match_previous.destroy                  
                end
                #if current change line change record event = new  
                if previous_changes_for_specline.event == 'new' 
                  #update specline_id of all previous changes for existing change record specline with specline of new changed line
                  update_specline_id_prior_changes(@check_new_match_previous.specline_id, @specline.id)              

                  current_matched_specline = Specline.where(:id => @check_new_match_previous.specline_id).first
              
                  #update change record of selected line to reflect               
                  previous_changes_for_specline.specline_id = @check_new_match_previous.specline_id
                  previous_changes_for_specline.linetype_id = current_matched_specline.linetype_id
                  previous_changes_for_specline.txt3_id = current_matched_specline.txt3_id
                  previous_changes_for_specline.txt4_id = current_matched_specline.txt4_id
                  previous_changes_for_specline.txt5_id = current_matched_specline.txt5_id
                  previous_changes_for_specline.txt6_id = current_matched_specline.txt6_id
                  previous_changes_for_specline.user_id = current_user.id
                  previous_changes_for_specline.save
                  #update specline_id of all previous changes for selected change record specline with specline of matched change line
                  update_specline_id_prior_changes(previous_changes_for_specline.specline_id, @check_new_match_previous.specline_id)
              
                  @check_new_match_previous.destroy
                end                               
              end
            end          
          end            
      end 
     end           
   end  
  end


    
def txt1_insert_line(specline, previous_specline, subsequent_specline_lines)
  check_linetype = Linetype.find(previous_specline.linetype_id)
  if check_linetype.txt1 == true
    specline.txt1_id = previous_specline.txt1_id + 1
    specline.save
    
   if subsequent_specline_lines.count == 1
     update_subsequent_lines_last(subsequent_specline_lines, specline.txt1_id)    
   else
    update_subsequent_lines(subsequent_specline_lines, specline.txt1_id)
  end
  end
end

                                                                                                                                           
def txt1_delete_line(specline) 
  check_linetype = Linetype.find(specline.linetype_id)

  previous_clauseline = specline.clause_line - 1 
    get_previous_specline_line = Specline.where("project_id = ? AND clause_id = ? AND clause_line = ?", specline.project_id, specline.clause_id, previous_clauseline).order("clause_line").last
    check_linetype = Linetype.find(get_previous_specline_line.linetype_id)
      if check_linetype.txt1 == true
        set_txt1_id = get_previous_specline_line.txt1_id
      else
        set_txt1_id = 0
      end  
    subsequent_clause_lines = Specline.where("project_id = ? AND clause_id = ? AND clause_line > ?", specline.project_id, specline.clause_id, specline.clause_line).order("clause_line")
    update_subsequent_lines(subsequent_clause_lines, set_txt1_id)

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
      previous_clauseline = specline.clause_line - 1   
      get_previous_specline_line = Specline.where("project_id = ? AND clause_id = ? AND clause_line = ?", specline.project_id, specline.clause_id, previous_clauseline).last
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


  def  specline_current_text_match_check(specline_update, current_revision)

      specline_hash = {}      
      linetype = Linetype.where(:id => specline_update.linetype_id).first
      
      if linetype[:txt3] == true     
        specline_hash['txt3s.text'] = specline_update.txt3.text
      end
      if linetype[:txt4] == true     
        specline_hash['txt4s.text'] = specline_update.txt4.text
      end
      if linetype[:txt5] == true     
        specline_hash['txt5s.text'] = specline_update.txt5.text
      end
      if linetype[:txt6] == true     
        specline_hash['txt6s.text'] = specline_update.txt6.text
      end
      specline_hash[:revision_id] = current_revision.id
      specline_hash[:project_id] = specline_update.project_id
      specline_hash[:clause_id] = specline_update.clause_id
      specline_hash[:linetype_id] = specline_update.linetype_id 

      @check_new_match_previous = Change.joins(:txt3, :txt4, :txt5, :txt5).where(specline_hash).first

  end
  
  #update specline_id of all precious changes for existing change record specline with specline of new line
  def update_specline_id_prior_changes(previous_change_specline_id, new_specline_id)
    
    prior_specline_changes = Change.where('specline_id =?', previous_change_specline_id)
    prior_specline_changes.each do |prior_change|
      prior_change.specline_id = new_specline_id
      prior_change.save
    end  
  end
   
#end of class  
end