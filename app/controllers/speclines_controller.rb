class SpeclinesController < ApplicationController

skip_before_filter :prepare_for_mobile, :except => [:mob_edit_specline, :mob_edit_linetype, :mob_specline_templates, :mob_show_clauses, :mob_show_clauses_del, :mob_delete, :mob_new_specline, :mob_line_update]

before_filter :require_user
before_filter :check_project_ownership, :except => [:add_clause, :edit_clauses, :guidance, :mob_edit_specline, :mob_change_linetype, :mob_update, :mob_line_update, :mob_specline_templates, :mob_delete_clause, :mob_delete, :mob_add_clause, :mob_show_clauses, :mob_show_clauses_del, :mob_new_specline]
before_filter :check_project_ownership_mob, :except => [:add_clause, :manage_clauses, :manage_clauses_2, :edit_clauses, :edit, :new_specline, :move_specline, :update_specline_3, :update_specline_4, :update_specline_5, :update_specline_6, :update, :delete_specline, :delete_clause, :guidance, :mob_delete, :mob_new_specline, :mob_line_update]

before_filter :prepare_for_mobile

layout "projects", :except => [:mob_edit_specline, :mob_change_linetype, :mob_specline_templates, :mob_show_clauses]

def manage_clauses
      
    @projects = Project.where('company_id =?', current_user.company_id).order("code") 
    
    @specline = Specline.find(params[:id])
    @current_subsection = Subsection.joins(:clauserefs => :clauses).where('clauses.id' => @specline.clause_id).first
 
    #call to protected method that establishes text to be shown for project revision status
    current_revision_render(@current_project)

#####this does not work

      if params[:selected_template_id].blank? == true    
      @current_project_template = Project.find(@current_project.parent_id)
      else
      @current_project_template = Project.find(params[:selected_template_id])
      end
          
    #new variable that contains only those projects that have the selected subsection    
    project_templates = Project.where("id != ? AND company_id =?", @current_project.id, current_user.company_id).order("code")
    if current_user.company_id != 1
      master_templates = Project.where("company_id =?", 1)
      @project_templates =  project_templates + master_templates
    else
      admin_templates = Project.where("company_id =?", 2)
      @project_templates =  project_templates + admin_templates
    end
    project_id_array = @project_templates.collect{|item1| item1.id}.sort
 
    relevant_clauses_array = Clause.joins(:clauseref).select('DISTINCT(clauses.id)').where('clauserefs.subsection_id' => @current_subsection.id).collect{|item1| item1.id}.sort
    relevant_templates_array = Specline.select('DISTINCT project_id').where(:project_id => project_id_array, :clause_id => relevant_clauses_array).collect{|item1| item1.project_id}.sort
    @selectable_templates = Project.where(:id => relevant_templates_array)  
    

    
    
      
    #specline_line_array = Specline.where("project_id = ?", @current_project.id).collect{|item1| item1.clause_id}.sort     
    clause_line_array = Clause.joins(:clauseref, :speclines).where('speclines.project_id' => @current_project.id, 'clauserefs.subsection_id' => @current_subsection.id).collect{|item2| item2.id}.sort

    #template_specline_line_array = Specline.where("project_id = ?", @current_project_template.id).collect{|item1| item1.clause_id}.sort    
    template_clause_line_array = Clause.joins(:clauseref, :speclines).where('speclines.project_id' => @current_project_template.id, 'clauserefs.subsection_id' => @current_subsection.id).collect{|item2| item2.id}.sort

   unused_clause_line_array = template_clause_line_array - clause_line_array
    @template_project_clauses = Clause.includes(:clauseref).where(:id => unused_clause_line_array).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause')
    @current_project_clauses = Clause.includes(:clauseref).where(:id => clause_line_array).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause')
 
     
end
#########################################################
def manage_clauses_2
      
    @projects = Project.where('company_id =?', current_user.company_id).order("code") 
    
    @specline = Specline.find(params[:id])
    @current_subsection = Subsection.joins(:clauserefs => :clauses).where('clauses.id' => @specline.clause_id).first
 
    #call to protected method that establishes text to be shown for project revision status
    current_revision_render(@current_project)
    
    #####this does not work
      if params[:selected_template_id].blank? == true    
      @current_project_template = Project.find(@current_project.parent_id)
      else
      @current_project_template = Project.find(params[:selected_template_id])
      end#####this does not work
         
    #new variable that contains only those projects that have the selected subsection    
    project_templates = Project.where("id != ? AND company_id =?", @current_project.id, current_user.company_id).order("code")
    master_templates = Project.where("company_id =?", 1)
    @project_templates =  project_templates + master_templates
    project_id_array = @project_templates.collect{|item1| item1.id}.sort
 
    relevant_clauses_array = Clause.joins(:clauseref).select('DISTINCT(clauses.id)').where('clauserefs.subsection_id' => @current_subsection.id).collect{|item1| item1.id}.sort
    relevant_templates_array = Specline.select('DISTINCT project_id').where(:project_id => project_id_array, :clause_id => relevant_clauses_array).collect{|item1| item1.project_id}.sort
    @selectable_templates = Project.where(:id => relevant_templates_array)  
    
      
    specline_line_array = Specline.select('DISTINCT clause_id').where("project_id = ?", @current_project.id).collect{|item1| item1.clause_id}.sort     
    clauseref_id_array = Clauseref.joins(:clauses).select('DISTINCT(clauserefs.id)').where('clauses.id' => specline_line_array, :subsection_id => @current_subsection.id).collect{|item2| item2.id}.sort

    template_specline_line_array = Specline.select('DISTINCT clause_id').where("project_id = ?", @current_project_template.id).collect{|item1| item1.clause_id}.sort    
    template_clauseref_id_array = Clauseref.joins(:clauses).select('DISTINCT(clauserefs.id)').where('clauses.id' => specline_line_array, :subsection_id => @current_subsection.id).collect{|item2| item2.id}.sort

    @list_of_clauses_in_use = Array.new
    
  #array of clause references not in the project but that are in the template 
  clauserefs_not_in_current_project = template_clauseref_id_array - clauseref_id_array
  
  possible_clauserefs_in_both_projects = template_clauseref_id_array + clauseref_id_array 
  clauserefs_in_both_projects = possible_clauserefs_in_both_projects.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
    
    
   clauserefs_in_both_projects.each_with_index do |clauseref, i|
    
  #check if clause title is a match
    #gets copy of clause for current project where clausref matches
    current_clauseref_clause = Clause.where(:id => specline_line_array, :clauseref_id => clauseref).first
    #gets copy of clause for template project where clausref matches
    template_clauseref_clause = Clause.where(:id => template_specline_line_array, :clauseref_id => clauseref).first
    
        
    if template_clauseref_clause.clausetitle_id == current_clauseref_clause.clausetitle_id
    #title match
      #check content 
      check_current_speclines = Specline.where(:clause_id => current_clauseref_clause.id, :project_id => @current_project.id)
      check_template_speclines = Specline.where(:clause_id => template_clauseref_clause.id, :project_id => @current_project_template.id)
    
      if check_current_speclines.length == check_template_speclines.length
      #if same number of lines
        #check_current_speclines.delete("id")
        #check_template_speclines.delete("id")
    
        #check_if_different = check_current_speclines.diff(check_template_speclines)
            
      check_current_speclines.each do |specline|


      
      
        if !(check_current_speclines.to_a - check_template_speclines.to_a).empty? #=> true
          #content matches
          next
        else
          #content does not match
          full_title = template_clauseref_clause.clause_full_title + ' - *(content differs)'    
        end
        end
      else
        #content does not match
        full_title = template_clauseref_clause.clause_full_title + ' - *(content differs)'         
      end   
    else
    #title not match
      #check content 
      check_current_speclines = Speclines.where(:clause_id => current_clauseref_clause.id, :project_id => @current_project.id)
      check_template_speclines = Speclines.where(:clause_id => template_clauseref_clause.id, :project_id => @current_project_template.id)
    
      #check_current_speclines.delete("id")
      #check_template_speclines.delete("id")
    
      #check_if_different = check_current_speclines.diff(check_template_speclines)

      
      if (check_current_speclines.to_a - check_template_speclines.to_a).empty? #=> true
        #content matches
        full_title = template_clauseref_clause.clause_full_title + ' - *(title differs, current title is ' + current_clauseref_clause.clausetitle.text + ')' 
      else
        #content does not match
        full_title = template_clauseref_clause.clause_full_title + ' - *(title and content differ, current title is ' + current_clauseref_clause.clausetitle.text + ')'    
      end     
    end
     
    @list_of_clauses_in_use[i] = [full_title, template_clauseref_clause.id]
     
   end
    
    @both_project_clauses = @list_of_clauses_in_use.compact
    
    @template_project_clauses = Clause.joins(:clauseref).where(:id => template_specline_line_array, :clauseref_id => clauserefs_not_in_current_project).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause')
   
    @current_project_clauses = Clause.joins(:clauseref).where(:id => specline_line_array, :clauseref_id => clauseref_id_array).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause')
  
    
end



#############################################################
def edit_clauses

    @current_project = Project.where('id = ? AND company_id =?', params[:project_id], current_user.company_id).first
       
    if @current_project.blank?
      redirect_to log_out_path
    else

	clauses_array = Clause.where(:id => params[:project_clauses]).collect{|i| i.id}
	clauses_array_existing = Specline.joins(:clause => :clauseref).where(:project_id => params[:project_id], 'clauserefs.subsection_id' => params[:subsection_id]).collect{|i| i.clause_id}.uniq

	clauses_to_add = clauses_array - clauses_array_existing
	if !clauses_to_add.blank?
		speclines_to_add = Specline.where(:project_id => params[:template_id], :clause_id => clauses_to_add) 
		speclines_to_add.each do |line_to_add|
			@new_specline = Specline.new(line_to_add.attributes.merge(:project_id => params[:project_id]))
			@new_specline.save
			@clause_change_record = 2
			record_new
		end                   
	end

	clauses_to_delete = clauses_array_existing - clauses_array
	if !clauses_to_delete.blank?       
    specline_lines_to_deleted = Specline.where(:project_id => params[:project_id], :clause_id => clauses_to_delete)      
    specline_lines_to_deleted.each do |existing_specline_line|
      @specline = existing_specline_line
      @clause_change_record = 2
      record_delete  
      existing_specline_line.destroy
    end
      
    @current_revision = Revision.where('project_id = ?', @current_project.id).last


    previous_changes_to_clause = Change.where(:project_id => @current_project.id, :clause_id => clauses_to_delete, :revision_id => @current_revision.id)
    if !previous_changes_to_clause.blank?
      previous_changes_to_clause.each do |previous_change|
        previous_change.clause_add_delete = 2
        previous_change.save
      end    
    end
	end 

  subsection_clauses_array = Clause.joins(:clauseref).where('clauserefs.subsection_id' => params[:subsection_id]).collect{|i| i.id}.uniq
  get_valid_spline_ref = Specline.where(:project_id => params[:project_id], :clause_id => subsection_clauses_array).last

  if get_valid_spline_ref.blank?
    redirect_to(:controller => "projects", :action => "manage_subsections", :id => params[:project_id], :selected_template_id => params[:template_id])
  else
    redirect_to(:controller => "speclines", :action => "manage_clauses", :id => get_valid_spline_ref.id, :project_id => params[:project_id], :selected_template_id => params[:template_id], :subsection_id => params[:subsection_id])
  end
  
  end
end

def add_clause
  
    @current_project = Project.where('id = ? AND company_id =?', params[:project_id], current_user.company_id).first
       
    if @current_project.blank?
      redirect_to log_out_path
    end  
   
    @existing_clause = Clause.where('id = ?', params[:existing_clause]).first 
   
    specline_lines_to_deleted = Specline.where(:project_id => params[:project_id], :clause_id => @existing_clause.id)
    if !specline_lines_to_deleted.blank?       
       
      specline_lines_to_deleted.each do |existing_specline_line|
        @specline = existing_specline_line
        @clause_change_record = 2
        record_delete  
        existing_specline_line.destroy
      end 
    end  
     
    speclines_to_add = Specline.where(:project_id => params[:template_id], :clause_id => @existing_clause.id) 
    speclines_to_add.each do |line_to_add|
      @new_specline = Specline.new(line_to_add.attributes.merge(:project_id => params[:project_id]))
      @new_specline.save
      @clause_change_record = 2
      record_new
    end
                       
    redirect_to(:controller => "speclines", :action => "manage_clauses", :id => params[:id], :project_id => params[:project_id])
 end  



  # GET
  def new_specline

    @specline = Specline.find(params[:id])
    
    @current_project = Project.where('id = ? AND company_id =?', @specline.project_id, current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end
     
    #call to protected method in application controller that changes the clause_line ref in any subsequent speclines    
   existing_subsequent_specline_lines = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?', @specline.clause_id, @specline.project_id, @specline.clause_line).order('clause_line')    
    update_subsequent_specline_clause_line_ref(existing_subsequent_specline_lines, 'new', @specline)
      
    if @specline.clause_line == 0
      linetype_id = 3
    else
      linetype_id = @specline.linetype_id
    end 
      
     @new_specline = Specline.new do |n|        
            n.project_id = @specline.project_id 
            n.clause_id = @specline.clause_id 
            n.clause_line = @specline.clause_line + 1
            n.txt1_id = @specline.txt1_id
            n.txt2_id = @specline.txt2_id
            n.txt3_id = @specline.txt3_id
            n.txt4_id = @specline.txt4_id
            n.txt5_id = @specline.txt5_id
            n.txt6_id = @specline.txt6_id
            n.linetype_id = linetype_id
          end
          @new_specline.save
  
    #if other lines of clause have been deleted in same revision then amended to recorded change event for line
      @current_revision = Revision.where('project_id = ?', @specline.project_id).last
      previous_change_to_clause = Change.where('project_id = ? AND clause_id = ? AND revision_id =?', @specline.project_id, @specline.clause_id, @current_revision.id).order('created_at').last
      if !previous_change_to_clause.blank?  
          @clause_change_record = previous_change_to_clause.clause_add_delete      
      end
               
    #call to private method that records addition of line in Changes table
    record_new    
    #change prefixs to clauselines in clause
    txt1_insert_line(@new_specline, @specline, existing_subsequent_specline_lines)
      if !@subsequent_prefixes.blank?
        @subsequent_prefixes.compact
      end
    end
       
    respond_to do |format|
        format.js   { render :new_specline, :layout => false } 
  end



def move_specline
    
    @selected_specline = @specline #obtained in before filter
    

###general stuff
    prefixed_linetypes_array = Linetype.where('txt1 = ?', 1).collect{|i| i.id}

####old location information
#old clause information
    old_limit_ref = @selected_specline.clause_line
    old_clause_line_limit = old_limit_ref - 2 
    previous_speclines = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?', @selected_specline.clause_id,  @selected_specline.project_id, old_clause_line_limit).order('clause_line')
    previous_specline_id_array = previous_speclines.collect{|i| i.id}
    previous_specline_id_array_length = previous_specline_id_array.length
#old position information
    #@selected_specline
#id of line above old position
    #selected_specline_id_location = previous_specline_id_array.index(@selected_specline.id)
    #old_above_id_location = selected_specline_id_location - 1
    old_above_specline = previous_speclines[0]#old_above_id_location]
#id of line below old position
    #old_below_id_location = selected_specline_id_location + 1
    old_below_specline = previous_speclines[2]#old_below_id_location]


#####old location tidy up
#renumber clause_lines
  if previous_specline_id_array_length > 2
    old_above_clauseline_ref = old_above_specline.clause_line
    last_array_item_ref = previous_specline_id_array_length - 1

    for i in (2..last_array_item_ref) do
      specline_to_change = previous_speclines[i]
      specline_to_change.clause_line = i - 1 + old_above_clauseline_ref 
      specline_to_change.save
    end
  end

#renumber prefixes
#check if line had prefix
if prefixed_linetypes_array.include?(@selected_specline.linetype_id)

          if !prefixed_linetypes_array.include?(old_above_specline.linetype_id)
            set_txt1_id = 0
          else
            set_txt1_id = old_above_specline.txt1_id #- 1
          end
          
          if previous_speclines.length > 2
            subsequent_clause_lines = previous_speclines[2..last_array_item_ref]
            update_subsequent_lines_on_move(subsequent_clause_lines, set_txt1_id)
                  if !@subsequent_prefixes.blank?
                    @previous_prefixes = @subsequent_prefixes.compact
                  end
          end    
else #if did not have prefix then update only if above and below had prefixes
  if prefixed_linetypes_array.include?(old_above_specline.linetype_id)
    if !old_below_specline.blank?
    if prefixed_linetypes_array.include?(old_below_specline.linetype_id)
          set_txt1_id = old_above_specline.txt1_id
          subsequent_clause_lines = previous_speclines[2..last_array_item_ref]
          update_subsequent_lines_on_move(subsequent_clause_lines, set_txt1_id)
           if !@subsequent_prefixes.blank?
                    @previous_prefixes = @subsequent_prefixes.compact
                  end 
    end
    end
  end 
end



####new location information
#new position information
######    
    array_as_string = params[:table_id_array]
    id_array = array_as_string.split(",").map { |s| s.to_s }
   # id_as_string = params[:id]
   # b = a.to_i
    array_location = id_array.index(params[:id])

#id of new above position
if array_location == 0  
    new_above_specline = Specline.where('clause_id = ? AND project_id = ? AND clause_line = ?', @selected_specline.clause_id,  @selected_specline.project_id, 0).first  
else

    new_above_id_location = array_location - 1
    new_above_specline_id = id_array[new_above_id_location]
    new_above_specline = Specline.where(:id => new_above_specline_id).first
end
    @new_above_specline = new_above_specline
    new_limit_ref = new_above_specline.clause_line
    new_above_clauseline_ref = new_above_specline.clause_line
########
   
#new clause information

    new_clause_line_limit = new_limit_ref - 1
    next_speclines = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?', new_above_specline.clause_id,  new_above_specline.project_id, new_clause_line_limit).order('clause_line')
    next_specline_id_array = next_speclines.collect{|item| item.id}
    next_specline_id_array_length = next_specline_id_array.length
#id of new below position

    new_below_specline = next_speclines[1]

  if !new_below_specline.blank?   
      
  if next_specline_id_array.include?(@selected_specline.id)
    index_of_id = next_specline_id_array.index(@selected_specline.id)
    next_speclines.delete_at(index_of_id)
    last_array_item_ref = next_specline_id_array_length - 2
  else
    last_array_item_ref = next_specline_id_array_length - 1
  end
    
  if next_specline_id_array_length > 1
    for i in (1..last_array_item_ref) do
      specline_to_change = next_speclines[i]
      specline_to_change.clause_line = i + 1 + new_above_clauseline_ref
      specline_to_change.save
    end
  end

end
  #renumber prefixes
#check if moved line had prefix

if prefixed_linetypes_array.include?(@selected_specline.linetype_id)

    if prefixed_linetypes_array.include?(new_above_specline.linetype_id)
     if !new_below_specline.blank? 
      if prefixed_linetypes_array.include?(new_below_specline.linetype_id)
      #if both do
       new_selected_txt1_id = new_above_specline.txt1_id
        selected_specline_new_txt1_id = new_selected_txt1_id + 1
        subsequent_clause_lines = next_speclines[1..last_array_item_ref]
        update_subsequent_lines_on_move(subsequent_clause_lines, selected_specline_new_txt1_id)
        if !@subsequent_prefixes.blank?
          @subsequent_prefixes.compact
        end 
      else
      #if above does but below does not
        new_selected_txt1_id = new_above_specline.txt1_id
        selected_specline_new_txt1_id = new_selected_txt1_id + 1 
      end
     else
        new_selected_txt1_id = new_above_specline.txt1_id
        selected_specline_new_txt1_id = new_selected_txt1_id + 1 
       
     end
    else
     if !new_below_specline.blank? 
      if prefixed_linetypes_array.include?(new_below_specline.linetype_id)
      #if above does not and below does
        selected_specline_new_txt1_id = 1
        subsequent_clause_lines = next_speclines[1..last_array_item_ref]
        update_subsequent_lines_on_move(subsequent_clause_lines, new_above_specline.txt1_id)
        if !@subsequent_prefixes.blank?
          @subsequent_prefixes.compact
        end 
      else
      #if both do not
        selected_specline_new_txt1_id = 1
      end
     else
      #if both do not
      selected_specline_new_txt1_id = 1
     end
    end

else #if did not have prefix then update only if above and below had prefixes

    if prefixed_linetypes_array.include?(new_above_specline.linetype_id) 
     if !new_below_specline.blank? 
      if prefixed_linetypes_array.include?(new_below_specline.linetype_id)
      #if both do
        subsequent_clause_lines = next_speclines[1..next_specline_id_array_length]
        update_subsequent_lines_on_move(subsequent_clause_lines, 0) 
        if !@subsequent_prefixes.blank?
          @subsequent_prefixes.compact
        end      
      end
     end 
    end
    selected_specline_new_txt1_id = 1 
end

#tracking changes

  if new_above_specline.clause_id != old_above_specline.clause_id 
    @new_specline = Specline.create(@selected_specline.attributes.merge(:txt1_id => selected_specline_new_txt1_id, :clause_id => new_above_specline.clause_id, :clause_line => new_above_clauseline_ref + 1))
      @current_revision = Revision.where('project_id = ?', @new_specline.project_id).last
      previous_change_to_clause = Change.where('project_id = ? AND clause_id = ? AND revision_id =?', @new_specline.project_id, @new_specline.clause_id, @current_revision.id).order('created_at').last
      if !previous_change_to_clause.blank?  
        @clause_change_record = previous_change_to_clause.clause_add_delete      
      end
    record_new  
    
    @specline = @selected_specline
    @specline.destroy
    record_delete
      @old_specline_ref = @selected_specline.id
      @updated_specline = Specline.where(:id => @new_specline.id).first
  else
    @old_specline_ref = @selected_specline.id
      @selected_specline.txt1_id = selected_specline_new_txt1_id
      @selected_specline.clause_line = new_above_clauseline_ref + 1
      @selected_specline.save
        @updated_specline = Specline.where(:id => @old_specline_ref).first
  end

    respond_to do |format|
      format.js   { render :move_specline, :layout => false } 
    end

end
  
  
  
  # GET /speclines/1/edit
  def edit     
    
    @linetypes = Linetype.where("id > ?", 2)        
  end
  
  

  # PUT /projects/update_specline_3/id
  def update_specline_3
    
    #before filter establishes @specline
    @specline_update = @specline
    #existing_text = @specline.txt3.text
    
    #application controller
    #removes white space and punctuation from end of text
    clean_text(params[:value])
    
    #value = new text
    if @value
          #save new text if exact match does not exist in Txt table
      #get new text info
      txt3_exist = Txt3.where('BINARY text =?', @value).first 
        if txt3_exist.blank?
          new_txt3_text = Txt3.create(:text => @value)
        else
          new_txt3_text = txt3_exist
        end
     
      #check if new text is similar to old text 
      check_text_similartity = @specline.txt3.text.casecmp(@value)
      if check_text_similartity == 0
        #if new text is similar to old text save change to text only - do not create change record
        @specline_update.txt3_id = new_txt3_text.id   
        @specline_update.save 
      else
        #if new text is not similar to old text save change to text and create change record
        @specline_update.txt3_id = new_txt3_text.id 
          record_change  
        @specline_update.save
      end
    end
    render :text=>  @value   
  end  
  
  
  # PUT /projects/update_specline_4/id
  def update_specline_4
    
    @specline_update = @specline

    #application controller
    #removes white space and punctuation from end of text
    clean_text(params[:value])
    
    #value = new text
    if @value
    txt4_exist = Txt4.where('BINARY text =?', @value).first
      if txt4_exist.blank?
         new_txt4_text = Txt4.create(:text => @value)
      else
         new_txt4_text = txt4_exist
      end
    
      #check if new text is similar to old text 
      check_text_similartity = @specline.txt4.text.casecmp(@value)
      if check_text_similartity == 0
        #if new text is similar to old text save change to text only - do not create change record
        @specline_update.txt4_id = new_txt4_text.id   
        @specline_update.save 
      else
        #if new text is not similar to old text save change to text and create change record
        @specline_update.txt4_id = new_txt4_text.id 
          record_change  
        @specline_update.save
      end
    end
    render :text=> params[:value]    
  end  

  
  # PUT /projects/update_specline_5/id
  def update_specline_5
    
    @specline_update = @specline
    
    #application controller
    #removes white space and punctuation from end of text
    clean_text(params[:value])
    
    #value = new text
    if @value
    txt5_exist = Txt5.where('BINARY text =?', @value).first
      if txt5_exist.blank?
         new_txt5_text = Txt5.create(:text => @value)
      else
         new_txt5_text = txt5_exist
      end
    
      #check if new text is similar to old text 
      check_text_similartity = @specline.txt5.text.casecmp(@value)
      if check_text_similartity == 0
        #if new text is similar to old text save change to text only - do not create change record
        @specline_update.txt5_id = new_txt5_text.id   
        @specline_update.save 
      else
        #if new text is not similar to old text save change to text and create change record
        @specline_update.txt5_id = new_txt5_text.id 
          record_change  
        @specline_update.save
      end
    end
    render :text=> params[:value] 
  end

  
  # PUT /projects/update_specline_6/id
  def update_specline_6
    
    @specline_update = @specline
    
    #application controller
    #removes white space and punctuation from end of text
    clean_text(params[:value])
    
    #value = new text
    if @value
    txt6_exist = Txt6.where('BINARY text =?', @value).first
      if txt6_exist.blank?
         new_txt6_text = Txt6.create(:text => @value)
      else
         new_txt6_text = txt6_exist
      end
    
      #check if new text is similar to old text 
      check_text_similartity = @specline.txt6.text.casecmp(@value)
      if check_text_similartity == 0
        #if new text is similar to old text save change to text only - do not create change record
        @specline_update.txt6_id = new_txt6_text.id   
        @specline_update.save 
      else
        #if new text is not similar to old text save change to text and create change record
        @specline_update.txt6_id = new_txt6_text.id 
          record_change  
        @specline_update.save
      end
    end
    render :text=> params[:value]   
  end
  
  # PUT /speclines/1
  # PUT /speclines/1.xml
  def update

    @specline_update = @specline
    #private method to update txt1 values following change to specline_line linetype
    
    old_linetype = Linetype.find(@specline.linetype_id)
    new_linetype = Linetype.find(params[:specline][:linetype_id])  
    
    if old_linetype.txt1 != new_linetype.txt1  
      txt1_change_linetype(@specline, old_linetype, new_linetype)
        if !@subsequent_prefixes.blank?
          @subsequent_prefixes.compact
        end 
    end
    #call to private method that records change to line in Changes table
    
    #only record change if linetype is changed ignoring txt1        
    old_linetype_array = [old_linetype.txt3, old_linetype.txt4, old_linetype.txt5, old_linetype.txt6]    
    new_linetype_array = [new_linetype.txt3, new_linetype.txt4, new_linetype.txt5, new_linetype.txt6]    
    if new_linetype_array != old_linetype_array
      record_change 
    end
     
    @specline_update.update_attributes(params[:specline])
  
  end

  def delete_clause
    
    @array_of_lines_deleted = []
    
    @specline = Specline.find(params[:id])
    @current_project = Project.where('id = ? AND company_id =?', @specline.project_id, current_user.company_id).first
    @current_revision = Revision.where('project_id = ?', @current_project.id).last
    
    if @current_project.blank?
      redirect_to(:controller => "devise/sessions", :action => "destroy")
    else
        
    selected_clause_title = @specline
    @clause_title_to_delete = @specline.id    
    #selected_clause_title.destroy
    
    #clause = Clause.find(@specline.clause_id)
    #adds in parent clause title line where clause has parent clause
    #add_parent_clause(clause, @current_project)

    
    clause_lines = Specline.where(:project_id => @specline.project_id, :clause_id => @specline.clause_id).order('clause_line')    
      clause_lines.each_with_index do |clause_line, i|
    
        @array_of_lines_deleted[i] = clause_line.id 
        @specline = clause_line
        #call to private method that record deletion of line in Changes table
        @clause_change_record = 2
                
        record_delete    
        clause_line.destroy   
      end
      
      @array_of_lines_deleted.compact
      
    previous_changes_to_clause = Change.where(:project_id => @current_project.id, :clause_id => @specline.clause_id, :revision_id => @current_revision.id)
    if !previous_changes_to_clause.blank?
      previous_changes_to_clause.each do |previous_change|
        previous_change.clause_add_delete = 2
        previous_change.save
      end    
    end 
    
    respond_to do |format|
      #format.html { redirect_to(project_path, :id => params[:id], :subsection =>  current_clause_type.subsection_id, :clausetype => current_clause_type.clausetype_id) }
      #format.xml  { head :ok }
      format.js  { render :delete_clause, :layout => false }
    end
    end
  end

  # DELETE /speclines/1
  # DELETE /speclines/1.xml
  def delete_specline
       
    check_specline = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?',  @specline.clause_id, @specline.project_id, 0).order('clause_line')  
  
        @spec_line_div = @specline.id

        #change prefixs to clauselines in clause    
        txt1_delete_line(@specline)
        if !@subsequent_prefixes.blank?
          @subsequent_prefixes.compact
        end                  
        @specline.destroy
        #call to private method that record deletion of line in Changes table
        record_delete
        
        #call to protected method in application controller that changes the clause_line ref in any subsequent speclines
        subsequent_specline_lines = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?', @specline.clause_id, @specline.project_id, @specline.clause_line).order('clause_line')        
        update_subsequent_specline_clause_line_ref(subsequent_specline_lines, 'delete', @specline)
        
            
        respond_to do |format|        
          if !mobile_device? 
            format.js   { render :delete_spec, :layout => false }
          else
            format.js   { render :mob_delete_spec, :layout => false }
          end       
        end    
  end


def guidance

      @selected_specline = Specline.where('id =?', params[:spec_id]).first
      #clause = Clause.includes(:clauseref).where('id =?', params[:id]).first

      clause = Clause.where(:id => params[:id]).first
      @guidenote = Guidenote.where(:id => clause.guidenote_id).first
      @guide_sponsors = Sponsor.includes(:supplier).where(:subsection_id => clause.clauseref.subsection_id)


    respond_to do |format|
        format.js   { render :guidance, :layout => false}
    end
end





def mob_edit_specline 
    @specline = Specline.where('id =?', params[:specline_id]).first
    current_revision_render(@current_project)
    @specline_clause_subsection = Clause.where(:id => @specline.clause_id).first  
      respond_to do |format|
        format.mobile {render :layout => "mobile"}
      end  
end

def mob_change_linetype
    current_revision_render(@current_project)    
    @linetypes = Linetype.where("id > ?", 2)
    @specline = Specline.where('id =?', params[:specline_id]).first       
      respond_to do |format|
        format.mobile {render :layout => "mobile"}
      end  
end

def mob_update
    @specline = Specline.where('id =?', params[:specline_id]).first
    @specline_update = @specline
    #private method to update txt1 values following change to specline_line linetype
    
    old_linetype = Linetype.find(@specline.linetype_id)
    new_linetype = Linetype.find(params[:linetype])  
    
    if old_linetype.txt1 != new_linetype.txt1  
      txt1_change_linetype(@specline, old_linetype, new_linetype)
    end
    #call to private method that records change to line in Changes table
    
    #only record change if linetype is changed ignoring txt1        
    old_linetype_array = [old_linetype.txt3, old_linetype.txt4, old_linetype.txt5, old_linetype.txt6]    
    new_linetype_array = [new_linetype.txt3, new_linetype.txt4, new_linetype.txt5, new_linetype.txt6]    
    if new_linetype_array != old_linetype_array
      record_change 
    end
     
    @specline_update.linetype_id = params[:linetype]
    @specline_update.save        

    redirect_to(:controller => "speclines", :action => "mob_edit_specline", :id => @specline_update.project_id, :specline_id => @specline_update.id)
end


def mob_line_update

    @specline = Specline.find(params[:id])
    
    @current_project = Project.where('id = ? AND company_id =?', @specline.project_id, current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end


      @specline_update = @specline
    
      if params[:specline][:txt3_text] != nil          
        value_3 = params[:specline][:txt3_text].strip.chomp(':').chomp(':').chomp(',').chomp('.').chomp('!').chomp('?').capitalize      
        new_txt3_text = Txt3.find_or_create_by_text(value_3) unless value_3.blank?
        if  @specline.txt3_id != new_txt3_text.id     
          @specline_update.txt3_id = new_txt3_text.id
          record_change
          @specline_update.save
        end
      end
      
      if params[:specline][:txt4_text] != nil          
        value_4 = params[:specline][:txt4_text].strip.chomp(':').chomp(':').chomp(',').chomp('.').chomp('!').chomp('?').capitalize      
        new_txt4_text = Txt4.find_or_create_by_text(value_4) unless value_4.blank?
        if  @specline.txt4_id != new_txt4_text.id     
          @specline_update.txt4_id = new_txt4_text.id
          record_change
          @specline_update.save
        end
      end
      
      if params[:specline][:txt5_text] != nil          
        value_5 = params[:specline][:txt5_text].strip.chomp(':').chomp(':').chomp(',').chomp('.').chomp('!').chomp('?').capitalize      
        new_txt5_text = Txt5.find_or_create_by_text(value_5) unless value_5.blank?
        if  @specline.txt5_id != new_txt5_text.id     
          @specline_update.txt5_id = new_txt5_text.id
          record_change
          @specline_update.save
        end
      end
      
      if params[:specline][:txt6_text] != nil          
        value_6 = params[:specline][:txt6_text].strip.chomp(':').chomp(':').chomp(',').chomp('.').chomp('!').chomp('?').capitalize      
        new_txt6_text = Txt6.find_or_create_by_text(value_6) unless value_6.blank?
        if  @specline.txt6_id != new_txt6_text.id     
          @specline_update.txt6_id = new_txt6_text.id
          record_change
          @specline_update.save
        end
      end
    redirect_to(:controller => "projects", :action => "show", :id => @current_project.id, :subsection => @specline.clause.clauseref.subsection_id)     
end

def mob_specline_templates

    @projects = Project.where('company_id =?', current_user.company_id).order("code")
    @current_subsection_id = params[:subsection_id] 

    #call to protected method that establishes text to be shown for project revision status
    current_revision_render(@current_project)
          
  #new variable that contains only those projects that have the selected subsection    
    project_templates = Project.where("id != ? AND company_id =?", @current_project.id, current_user.company_id).order("code")
    master_templates = Project.where("company_id =?", 1)
    @project_templates =  project_templates + master_templates
    project_id_array = @project_templates.collect{|item1| item1.id}.sort
 
    relevant_clauses_array = Clause.joins(:clauseref).where('clauserefs.subsection_id' => @current_subsection_id).collect{|item1| item1.id}.sort.uniq
    relevant_templates = Specline.select('DISTINCT project_id').where(:project_id => project_id_array, :clause_id => relevant_clauses_array)
    relevant_templates_array = relevant_templates.collect{|item1| item1.project_id}.sort
    @selectable_templates = Project.where(:id => relevant_templates_array) 


      respond_to do |format|
        format.mobile {render :layout => "mobile"}
      end  
end

def mob_show_clauses

    current_revision_render(@current_project)
    @current_template_project = Project.where('id =?', params[:template_id]).first
      
  ##Part A - following section established all the relevant specline lines, clauses, subsections and sections for the selected project
    specline_line_array = Specline.select('DISTINCT clause_id').where("project_id = ?", @current_project.id).collect{|item1| item1.clause_id}.sort    
    clause_line_array = Clause.joins(:clauseref).where(:id => specline_line_array, 'clauserefs.subsection_id' => params[:subsection_id]).collect{|item2| item2.id}.sort.uniq
     
  ##Part B - following section established all the relevant specline lines, clauses, subsections and sections for the selected project template
    template_specline_line_array = Specline.where("project_id = ?", params[:template_id]).collect{|item1| item1.clause_id}.sort    
    template_clause_line_array = Clause.joins(:clauseref).where(:id => template_specline_line_array, 'clauserefs.subsection_id' => params[:subsection_id]).collect{|item2| item2.id}.sort
  
    unused_clause_line_array = template_clause_line_array - clause_line_array
    @template_project_clauses = Clause.joins(:clauseref).where(:id => unused_clause_line_array).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause')

    @current_subsection_id =params[:subsection_id]

      respond_to do |format|
        format.mobile {render :layout => "mobile"}
      end  
end

def mob_show_clauses_del

    current_revision_render(@current_project)
      
  ##Part A - following section established all the relevant specline lines, clauses, subsections and sections for the selected project
    current_specline_clause_array = Specline.select('DISTINCT clause_id').where("project_id = ?", @current_project.id).collect{|item1| item1.clause_id}.sort      
    @current_subsection_clauses = Clause.joins(:clauseref).where(:id => current_specline_clause_array, 'clauserefs.subsection_id' => params[:subsection_id]).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause')

    @current_subsection_id =params[:subsection_id]
      respond_to do |format|
        format.mobile {render :layout => "mobile"}
      end  
end


def mob_add_clause

    specline_lines_to_be_copied = Specline.where(:project_id => params[:template_id], :clause_id => params[:add_clause_id])  
    #finds all specline lines with clauses that are within selected subsection of project template
      
    #create new lines
    specline_lines_to_be_copied.each do |existing_specline_line|
      @new_specline = Specline.new(existing_specline_line.attributes.merge({:project_id => params[:id]}))      
      @new_specline.save
      @clause_change_record = 2
      record_new
    end
      
    @clause_id =  params[:add_clause_id]
    #@last_available_clause = []


    #redirect_to(:controller => "speclines", :action => "mob_show_clauses", :id => @current_project.id, :subsection_id => params[:subsection_id], :template_id => params[:template_id])  
end


def mob_delete_clause
    
      @current_revision = Revision.where('project_id = ?', @current_project.id).last
      #finds all specline lines to be deleted with clauses that are within selected subsection of project template  

      specline_lines_to_be_deleted = Specline.where(:project_id => params[:id], :clause_id => params[:del_clause_id])  
      @clause_id = specline_lines_to_be_deleted.first.clause_id
      #destroy specline lines from project
      specline_lines_to_be_deleted.each do |existing_specline_line|
      
        #if existing_specline_line.clause_line != 0
          @specline = existing_specline_line
          @clause_change_record = 2
          #call to private method that record deletion of line in Changes table
          record_delete 
        #end     
      existing_specline_line.destroy
      end
      
      previous_changes_to_clause = Change.where(:project_id => @current_project.id, :clause_id => params[:del_clause_id], :revision_id => @current_revision.id)
      if !previous_changes_to_clause.blank?
        previous_changes_to_clause.each do |previous_change|
          previous_change.clause_add_delete = 2
          previous_change.save
        end    
      end
      
      subsection = Subsection.where('id=?', params[:subsection_id]).first
       
      subsection_clauses = Clause.joins(:clauseref).select('DISTINCT id').where('clauserefs.subsection_id' => params[:subsection_id])
      subsection_clauses_array = subsection_clauses.collect{|item| item.id}.uniq 
      get_valid_spline_ref = Specline.where(:project_id => params[:id], :clause_id => subsection_clauses_array).last

      if get_valid_spline_ref.blank?   
                        
        current_project_subsections = Subsection.select('DISTINCT section_id').where(:id => params[:subsection_id])
        subsection_array = current_project_subsections.collect{|item3| item3.section_id}.sort         
        array_of_subsections = Subsection.where(:section_id => subsection_array)
              
              subsection_clauses_array = Clause.joins(:clauseref).select('DISTINCT id').where('clauserefs.subsection_id' => array_of_subsections).collect{|item| item.id}
              get_valid_spline_ref_2 = Specline.where(:project_id => params[:project_id], :clause_id => subsection_clauses_array).last        
        if get_valid_spline_ref_2.blank?   
          redirect_to(:controller => "projects", :action => "project_sections", :id => @current_project.id)
        else
          redirect_to(:controller => "projects", :action => "project_subsections", :id => @current_project.id, :section => @subsection.section_id)
        end
      else
        #redirect_to(:controller => "speclines", :action => "mob_show_clauses_del", :id => @current_project.id, :subsection_id => params[:subsection_id])
      end
end   

  def mob_delete
    
      @specline = Specline.find(params[:id])
   
           @current_project = Project.where('id = ? AND company_id =?', @specline.project_id, current_user.company_id).first    
    if @current_project.blank?
      redirect_to log_out_path
    end
                  
    check_specline = Specline.includes('clause').where('clause_id = ? AND project_id = ? AND clause_line > ?',  @specline.clause_id, @specline.project_id, 0).order('clause_line').first  
    @spec_line_div =[]    

        @spec_line_div[0]= @specline.id
        @spec_line_div[1]= 'not_last_row'   
        #change prefixs to clauselines in clause    
        txt1_delete_line(@specline)        
        @specline.destroy
        #call to private method that record deletion of line in Changes table
        record_delete
                    
        #redirect_to(:controller => "projects", :action => "show", :id => @current_project.id, :subsection => check_specline.clause.subsection_id)    
    #respond_to do |format|
    #    format.js   { render :mob_delete, :layout => false }
    #end
  end

    # GET
  def mob_new_specline

    @specline = Specline.find(params[:id])
    
    @current_project = Project.where('id = ? AND company_id =?', @specline.project_id, current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end
     
    subsequent_specline_lines = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?', @specline.clause_id, @specline.project_id, @specline.clause_line).order('clause_line')
    total_number_lines = subsequent_specline_lines.length
    @array_subsequent_line_ids = subsequent_specline_lines.collect{|item| item.id} 
    
    #call to protected method in application controller that changes the clause_line ref in any subsequent speclines
    update_subsequent_specline_clause_line_ref(subsequent_specline_lines, total_number_lines, @specline)
      
    if @specline.clause_line == 0
      @new_specline = Specline.create(@specline.attributes.merge(:linetype_id => 3, :clause_line => @specline.clause_line + 1))
    else
      @new_specline = Specline.create(@specline.attributes.merge(:clause_line => @specline.clause_line + 1))
    end
   
    #if other lines of clause have been deleted in same revision then amended to recorded change event for line
      @current_revision = Revision.where('project_id = ?', @specline.project_id).last
      previous_change_to_clause = Change.where('project_id = ? AND clause_id = ? AND revision_id =?', @specline.project_id, @specline.clause_id, @current_revision.id).order('created_at').last
      if !previous_change_to_clause.blank?  
          @clause_change_record = previous_change_to_clause.clause_add_delete      
      end
               
    #call to private method that records addition of line in Changes table
    record_new    
    #change prefixs to clauselines in clause
    txt1_insert_line(@new_specline, @specline, subsequent_specline_lines)

   # respond_to do |format|
   #   format.js   { render :mob_new_specline, :layout => false}
   # end
    
    
    #redirect_to(:controller => "projects", :action => "show", :id => @current_project.id, :subsection => @specline.clause.subsection_id)    
  end


protected
def check_project_ownership

    @specline = Specline.find(params[:id])
    @current_project = Project.where('id = ? AND company_id =?', @specline.project_id, current_user.company_id).first
       
    if @current_project.blank?
      redirect_to log_out_path
    end
end

def check_project_ownership_mob
        @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first    
    if @current_project.blank?
      redirect_to log_out_path
    end
end



#end of class  
end