class ChangesController < ApplicationController

  def reinstate_clause     
    
    @current_revision = Revision.where('project_id =?', params[:project_id]).last   
    @reinstate_clause = params[:id]
     
      @changed_clause_lines = Change.where('clause_id =? AND revision_id =? AND project_id =?', params[:id], params[:revision_id], params[:project_id])
      event_type_check = @changed_clause_lines.collect{|item| item.event}.uniq

      if event_type_check[0] == 'new'
          @changed_clause_lines.each do |changed_clause_line|
             #delete title line as well
             
             
             @specline = Specline.find(changed_clause_line.specline_id)
              if changed_clause_line.revision_id != @current_revision.id
              #implement application controller event to create new change record for delete of line that was added previously
              @clause_change_record = 2
              record_delete
              @hide_line_in_view = true
              else
              changed_clause_line.destroy
              @hide_line_in_view = false
              end
            @specline.destroy
          end
      end

      if event_type_check[0] == 'deleted'     
        #establish clause_line of resinstated line
        @changed_clause_lines.each do |changed_clause_line|
          
        #call to private method to establish values of and save reinstated line
        reinstate_deleted_specline(changed_clause_line)
                
          if changed_clause_line.revision_id != @current_revision.id                 
          #implement application controller event to create new change record for creation of new line that has been reinstated
            @clause_change_record = 2
            record_new
            @hide_line_in_view = true
          else
            existing_delete_record = Change.where(:project_id => @new_specline.project_id, :linetype_id => @new_specline.linetype_id, :clause_id => @new_specline.clause_id, :txt3_id => @new_specline.txt3_id, :txt4_id => @new_specline.txt4_id, :txt5_id => @new_specline.txt5_id, :txt6_id => @new_specline.txt6_id, :event => 'deleted', :revision_id => @current_revision.id).first
            #if !existing_delete_record.blank?
            prior_specline_changes = Change.where(:specline_id => existing_delete_record.specline_id)
            prior_specline_changes.each do |prior_change|
              prior_change.specline_id = @new_specline.id
              prior_change.save
            end
          #end         
          changed_clause_line.destroy
          @hide_line_in_view = false 
          end
        end
      end        
  end



  def reinstate
    #!!!!this is for reinstatement within current revision only place if inside each scenario

    @current_revision = Revision.where('project_id =?', params[:project_id]).order('created_at').last       
    
    @change = Change.find(params[:id])
      if @change.event == 'new'
      @specline = Specline.find(@change.specline_id)
        if @change.revision_id != @current_revision.id
        #implement application controller event to create new change record for delete of line that was added previously
        record_delete
        @hide_line_in_view = true
        ##? add in redirect to reload the page if no changes against current project rev        
        else
        @change.destroy
        @hide_line_in_view = false
        end
      @specline.destroy
      end
      
      if @change.event == 'deleted'
        #call to private method to establish values of and save reinstated line
        reinstate_deleted_specline(@change)
                  
        if @change.revision_id != @current_revision.id        
          record_new
        @hide_line_in_view = true
        else
          existing_delete_record = Change.where(:project_id => @new_specline.project_id, :linetype_id => @new_specline.linetype_id, :clause_id => @new_specline.clause_id, :txt3_id => @new_specline.txt3_id, :txt4_id => @new_specline.txt4_id, :txt5_id => @new_specline.txt5_id, :txt6_id => @new_specline.txt6_id, :event => 'deleted', :revision_id => @current_revision.id).first
          #if !existing_delete_record.blank?
          prior_specline_changes = Change.where(:specline_id => existing_delete_record.specline_id)
            prior_specline_changes.each do |prior_change|
              prior_change.specline_id = @new_specline.id
              prior_change.save
            end
          #end         
          @change.destroy
          @hide_line_in_view = false          
        end       
      end 
      
      
      if @change.event == 'changed'
      #find specline record and update with old parameters
      changed_specline = Specline.find(@change.specline_id)
      @specline = changed_specline 
        if @change.revision_id != @current_revision.id
          record_change
          changed_specline.linetype_id = @change.linetype_id
          changed_specline.txt3_id = @change.txt3_id
          changed_specline.txt4_id = @change.txt4_id
          changed_specline.txt5_id = @change.txt5_id
          changed_specline.txt6_id = @change.txt6_id
          changed_specline.save
          @hide_line_in_view = true                    
        else        
          changed_specline.linetype_id = @change.linetype_id
          changed_specline.txt3_id = @change.txt3_id
          changed_specline.txt4_id = @change.txt4_id
          changed_specline.txt5_id = @change.txt5_id
          changed_specline.txt6_id = @change.txt6_id
          changed_specline.save
          @change.destroy
          @hide_line_in_view = false                              
        end
        old_linetype = Linetype.find(@specline.linetype_id) 
        new_linetype = Linetype.find(@change.linetype_id)
        txt1_change_linetype(changed_specline, old_linetype, new_linetype)         
      end
  end


private
  def reinstate_deleted_specline(changed_clause_line)
  
    @last_clause_line = Specline.where(:project_id => changed_clause_line.project_id, :clause_id => changed_clause_line.clause_id).last
    if @last_clause_line.blank?
      @insert_clause_line = 0
    else
      if @last_clause_line.clause_line == 0
        @insert_clause_line = 1
      else
        @insert_clause_line = @last_clause_line.clause_line + 1
      end
    end
                   
    linetype_check = Linetype.find(changed_clause_line.linetype_id)
    @txt1_id = 1
    if linetype_check.txt1 == true          
      last_txt1_line = Specline.where(:project_id => changed_clause_line.project_id, :clause_id => changed_clause_line.clause_id, :linetype_id => changed_clause_line.linetype_id).last
      if !last_txt1_line.blank?
        @txt1_id = last_txt1_line.txt1_id + 1
        #@insert_clause_line = last_txt1_line.clause_line + 1
        ##what happens to any lines after this
        if last_txt1_line != @last_clause_line
          subsequent_specline_lines = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?', last_txt1_line.clause_id, last_txt1_line.project_id, last_txt1_line.clause_line).order('clause_line')                
          total_number_lines = subsequent_specline_lines.length
          #call to privare method in application controller that changes the clause_line ref in any subsequent speclines
          update_subsequent_specline_clause_line_ref(subsequent_specline_lines, total_number_lines, last_txt1_line)                          
        end
      end
    end
                         
    @new_specline = Specline.new do |n|
      n.project_id = changed_clause_line.project_id
      n.clause_id = changed_clause_line.clause_id
      n.clause_line = @insert_clause_line
      n.linetype_id = changed_clause_line.linetype_id
      n.txt1_id = @txt1_id
      n.txt3_id = changed_clause_line.txt3_id
      n.txt4_id = changed_clause_line.txt4_id
      n.txt5_id = changed_clause_line.txt5_id
      n.txt6_id = changed_clause_line.txt6_id
    end
    @new_specline.save
  end 
   
end