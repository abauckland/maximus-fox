class ProjectsController < ApplicationController

before_filter :require_user
before_filter :check_project_ownership, :except => [:index, :new, :create, :edit_subsections, :show_tab_content]


layout "projects"

  # GET /project
  # GET /project.xml
  def index
    @projects = Project.where("company_id =?", current_user.company_id).order("code")     
    @current_project = @projects.first

    @tutorials = Help.all 
    
    if @projects.length == 1
      check_speclines = Specline.where(:project_id => @current_project.id).first
      if check_speclines.blank?
        @not_used = true
      end
    end
      
    #render :layout => false
      respond_to do |format|  
        format.html 
      end    
  end
          
  # GET /projects/1
  # GET /projects/1.xml
  def show      
    
    @projects = Project.where('company_id =?', current_user.company_id).order("code") 
  
    @current_project_template = Project.select('code, title').where('id = ?', @current_project.parent_id).first
    
    #call to protected method that restablishes text to be shown for project revision status
    current_revision_render(@current_project)

    #establish project clauses, subsections & sections    
    @project_subsections = Subsection.select('subsections.id, subsections.section_id, subsections.ref, subsections.text').joins(:clauserefs =>  [{:clauses => :speclines}]).where('speclines.project_id' => @current_project.id).uniq.sort  

    #if no contents redirect to manage_subsection page
    if @project_subsections.blank?
      redirect_to empty_project_project_path(@current_project.id)
    else

    array_project_subsection_ids = @project_subsections.collect{|i| i.id}
    array_project_section_ids = @project_subsections.collect{|i| i.section_id}.uniq.sort      

    # @project_sections = Section.where(:id => array_project_section_ids)
    @project_sections = Section.where(:id => array_project_section_ids)
    #check for other variables that are needed below

  
    #estabish list and current value for section and subsection select menues
    if params[:section].blank?
      if params[:subsection].blank?     
          @selected_key_section = @project_sections.first
          @selected_key_subsection = Subsection.select('id, guidepdf_id').where(:id => array_project_subsection_ids, :section_id => @selected_key_section.id).first    
      else         
          @selected_key_subsection = Subsection.find(params[:subsection])
          @selected_key_section = Section.select('id').where(:id => @selected_key_subsection.section_id).first
      end
    else
          @selected_key_section = Section.select('id').where(:id => params[:section]).first
          @selected_key_subsection = Subsection.where(:id => array_project_subsection_ids, :section_id => @selected_key_section.id).first      
    end
    @selected_subsections = Subsection.where(:id => array_project_subsection_ids, :section_id => @selected_key_section.id)

 #if @selected_key_section.id != 1
   # @current_project_clause_ids = Specline.select('DISTINCT clause_id').where('project_id = ?', @current_project.id).collect{|item1| item1.clause_id}.uniq.sort   
   
    #get all speclines for selected subsection

    @clausetypes = Clausetype.joins(:clauserefs => [:clauses => :speclines]).where('speclines.project_id' => @current_project, 'clauserefs.subsection_id' => @selected_key_subsection.id).uniq.sort 


    #selected_clauses = Clause.joins(:clauseref, :speclines).select('DISTINCT(clauses.id)').where('speclines.project_id' => @current_project.id, 'clauserefs.subsection_id' => @selected_key_subsection.id)
    #array_of_selected_clauses = selected_clauses.collect{|item6| item6.id}.uniq.sort

    
    @selected_specline_lines = Specline.includes(:txt1, :txt3, :txt4, :txt5, :txt6, :clause => [ :clausetitle, :guidenote, :clauseref => [:subsection]]).where(:project_id => @current_project.id, 'clauserefs.subsection_id' => @selected_key_subsection.id, 'clauserefs.clausetype_id' => @clausetypes.first.id).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause, clause_line')                           
#    @selected_specline_lines = Specline.includes(:txt1, :txt3, :txt4, :txt5, :txt6, :clause => [ :clausetitle, :guidenote, :clauseref => [:subsection]]).where(:project_id => @current_project.id, 'clauserefs.subsection_id' => @selected_key_subsection.id).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause, clause_line')                           

    
    #establish list of clausetypes to build tabulated view in show    
    #selected_clause_ids = selected_clauses.collect{|item| item.id}.uniq.sort        
    #clausetype_ids = Clausetype.joins(:clauserefs => :clauses).where('clauses.id' => selected_clause_ids).collect{|item1| item1.id}.uniq.sort 
    #@clausetypes = Clausetype.where(:id => clausetype_ids)
    #clauseypes less first
    #clausetype_ids.shift
    #@clausetypes = Clausetype.where(:id => clausetype_ids)
    
    if params[:clausetype].blank?
     @current_clausetype = @clausetypes.first 
    else
     @current_clausetype = Clausetype.select('id').where(:id => params[:clausetype]).first 
    end
#end    
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @project }
      end      
   end         
  end



  def show_tab_content
    current_project_id = params[:id]
    if params[:subsection_id]
      current_subsection_id = params[:subsection_id]
    else
      first_project_subsection = Subsection.select('subsections.id, subsections.section_id, subsections.ref, subsections.text').joins(:clauserefs =>  [{:clauses => :speclines}]).where('speclines.project_id' => current_project_id).first 
      current_subsection_id = first_project_subsection.id      
    end
    @clausetype_id = params[:clausetype_id]
    @selected_specline_lines = Specline.includes(:txt1, :txt3, :txt4, :txt5, :txt6, :clause => [:clausetitle, :guidenote, :clauseref => [:subsection]]).where(:project_id => current_project_id, 'clauserefs.subsection_id' => current_subsection_id, 'clauserefs.clausetype_id' => @clausetype_id).order('clauserefs.clause, clauserefs.subclause, clause_line')                           

    respond_to do |format|
      format.js  { render :show_tab_content, :layout => false } 
    end    
  end


  def empty_project
       
      @projects = Project.where('company_id =?', current_user.company_id).order("code")
      
      if @projects.length == 1
        @not_used = true
      end

  end

  
  # GET /projects/1/subsections
  # GET /projects/1/subsections.xml
  def manage_subsections
    
    current_project_and_templates(@current_project.id, current_user.company_id)
  
    #call to protected method that restablishes text to be shown for project revision status
    current_revision_render(@current_project)
   
     if params[:selected_template_id].blank? == true    
        @current_project_template = Project.find(@current_project.parent_id)
      else
        @current_project_template = Project.find(params[:selected_template_id])     
      end

   # clause_line_array = Clauseref.joins(:clauses => :speclines).where('speclines.project_id' => @current_project.id).collect{|item2| item2.subsection_id}.sort.uniq 
    clause_line_array = Subsection.joins(:clauserefs => [:clauses => :speclines]).where('speclines.project_id' => @current_project.id).collect{|item2| item2.id}.sort
   # template_clause_line_array = Clauseref.joins(:clauses => :speclines).where('speclines.project_id' => @current_project_template.id).collect{|item2| item2.subsection_id}.sort 
    template_clause_line_array = Subsection.joins(:clauserefs => [:clauses => :speclines]).where('speclines.project_id' => @current_project_template.id).collect{|item2| item2.id}.sort
     
    #clause_line_array = current_project_clauses.collect{|item2| item2.subsection_id}.sort       
    @current_project_subsections = Subsection.where(:id => clause_line_array)
  
    unused_clause_line_array = template_clause_line_array - clause_line_array
    @template_project_subsections = Subsection.where(:id => unused_clause_line_array)
    
    #if clause_line_array.blank?
   #   redirect_to empty_project_project_path(@current_project.id)
    #end
    
  end
  
  
  ##POST
  def add_subsections

    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    if @current_project.blank?
      redirect_to log_out_path
    end
    
    #subsection_list = Subsection.where(:id => params[:template_sections]).collect{|i| i.id}.uniq 
    #subsection_array = Clause.joins(:speclines, :clauseref).where('speclines.project_id' => params[:id]).collect{|i| i.clauseref.subsection_id}.uniq 
    #subsections_to_add = subsection_list- subsection_array

    speclines_to_add = Specline.joins(:clause => :clauseref).where(:project_id => params[:template_id], 'clauserefs.subsection_id' => params[:template_sections])

    speclines_to_add.each do |line_to_add|
		  @new_specline = Specline.new(line_to_add.attributes.merge(:project_id => params[:id]))
		  @new_specline.save
		  @clause_change_record = 3
		  record_new
    end                   

     redirect_to(:controller => "projects", :action => "manage_subsections", :id => params[:id], :selected_template_id => params[:template_id])     
  end


  ##POST
  def delete_subsections

    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    if @current_project.blank?
      redirect_to log_out_path
    end
    
    #subsection_list = Subsection.where(:id => params[:template_sections]).collect{|i| i.id}.uniq
    #subsection_array = Clause.joins(:speclines, :clauseref).where('speclines.project_id' => params[:id]).collect{|i| i.clauseref.subsection_id}.uniq 
    #subsections_to_delete = subsection_array - subsection_list

    speclines_to_delete = Specline.joins(:clause => :clauseref).where(:project_id => params[:id], 'clauserefs.subsection_id' => params[:project_sections])
    clauses_to_delete = speclines_to_delete.collect{|i| i.clause_id}.uniq.sort

    speclines_to_delete.each do |line_to_delete|        
      if line_to_delete.clause_line != 0       
        @specline = line_to_delete
        @clause_change_record = 3
        record_delete              
      end
    line_to_delete.destroy
    end

    @current_revision = Revision.where('project_id = ?', @current_project.id).last
    previous_changes_to_clause = Change.where(:project_id => params[:id], :clause_id => clauses_to_delete, :revision_id => @current_revision.id)
    if !previous_changes_to_clause.blank?
      previous_changes_to_clause.each do |previous_change|
      previous_change.clause_add_delete = 3
      previous_change.save
      end    
    end

     redirect_to(:controller => "projects", :action => "manage_subsections", :id => params[:id], :selected_template_id => params[:template_id])     
end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new
    @projects = Project.where(:company_id => current_user.company_id).order("code")
    @current_project=@projects.first
    @project_templates = Project.where(:company_id => [1, current_user.company_id]).order("company_id, code") 

  end


  # POST /projects
  # POST /projects.xml
  def create
  
  #if params[:project][:code].blank?

  #else
    @project = Project.new(params[:project])
    @project.company_id = current_user.company_id
    @projects = Project.where(:company_id => current_user.company_id).order("code")
    respond_to do |format|
      if @project.save
          set_current_revision = Revision.create(:project_id => @project.id, :user_id => current_user.id, :date => Date.today)
        #format.html { redirect_to(:controller => "projects", :action => "manage_subsections", :id => @project.id) }
        format.html { redirect_to(@project) }
        #format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
      @current_project = Project.where("company_id =?", current_user.company_id).order("code").first
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  #end
  end

  
  # GET /projects/1/edit
  def edit
    #check_project_ownership in before filter sets up variables for current_project
    current_project_and_templates(@current_project.id, current_user.company_id)
    @project = @current_project    
    project_status_array = [['Draft', 'Draft'],['Preliminary', 'Preliminary'], ['Tender', 'Tender'], ['Contract', 'Contract'], ['As Built', 'As Built']]
    current_status = @current_project.project_status
    current_status_index = project_status_array.index([current_status, current_status])
    project_status_array_last_index = project_status_array.length
    @available_status_array = project_status_array[current_status_index..project_status_array_last_index]
    
    #call to protected method that restablishes text to be shown for project revision status
    current_revision_render(@current_project)  
  end  
  

  def update_project
    @project = Project.find(params[:id])
                
    @project.update_attributes(params[:project])
    #after new project status set, check if status is 'draft' 
    if @project.project_status != 'Draft'
      #if status is not draft, check if revisions status has been changed to '-'
      check_rev_exists = Revision.where('project_id = ?', @project.id).first
      #if status has not been changed previously, change to '-' and record project status for revision
      if check_rev_exists.rev.blank?
        check_rev_exists.rev = '-'
        check_rev_exists.project_status = @project.project_status
        check_rev_exists.save
      #else just update with current project status in last revision record
      else
        current_project_rev = Revision.where('project_id = ?', @project.id).last
        current_project_rev.project_status = @project.project_status
        current_project_rev.save
      end
    end
         
    respond_to do |format|     
        format.html { redirect_to edit_project_path(@project)}   
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
    end
  end

protected
def check_project_ownership
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end
end

  
end