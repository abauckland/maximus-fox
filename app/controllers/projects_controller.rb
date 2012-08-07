class ProjectsController < ApplicationController

before_filter :require_user
before_filter :check_project_ownership, :except => [:index, :new, :create, :edit_subsections]
before_filter :prepare_for_mobile

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
        format.mobile 
      end    
  end
          
  # GET /projects/1
  # GET /projects/1.xml
  def show      
    
    @projects = Project.select('id, code, title').where('company_id =?', current_user.company_id).order("code") 
    @current_project_template = Project.select('code, title').where('id = ?', @current_project.parent_id).first
    
    #call to protected method that restablishes text to be shown for project revision status
    current_revision_render(@current_project)

    #establish project clauses, subsections & sections
    @current_project_clause_ids = Specline.select('DISTINCT clause_id').where('project_id = ?', @current_project.id).collect{|item1| item1.clause_id}.uniq.sort   
    
    current_project_subsection_ids = Subsection.joins(:clauserefs =>  [{:clauses => :speclines}]).where('speclines.project_id' => @current_project.id)   
    current_project_section_ids = current_project_subsection_ids.collect{|i| i.section_id}.uniq.sort      

    @project_sections = Section.where(:id => current_project_section_ids)

#check for other variables that are needed below


    #if no contents redirect to manage_subsection page
    if @project_sections.blank?
      redirect_to(:controller => "projects", :action => "empty_project", :id => @current_project.id)
    else
    
    #estabish list and current value for section and subsection select menues
    if params[:section].blank?
      if params[:subsection].blank?     
          @selected_key_section = @project_sections.first
          @selected_key_subsection = Subsection.select('id, guidepdf_id').where(:id => current_project_subsection_ids, :section_id => @selected_key_section.id).first    
      else         
          @selected_key_subsection = Subsection.find(params[:subsection])
          @selected_key_section = Section.select('id').where(:id => @selected_key_subsection.section_id).first
      end
    else
          @selected_key_section = Section.select('id').where(:id => params[:section]).first
          @selected_key_subsection = Subsection.select('id, www').where(:id => current_project_subsection_ids, :section_id => @selected_key_section.id).first      
    end
    @selected_subsections = Subsection.where(:id => current_project_subsection_ids, :section_id => @selected_key_section.id)

 #if @selected_key_section.id != 1
  
    #get all speclines for selected subsection
    selected_clauses = Clause.joins(:clauseref).select('DISTINCT(clauses.id)').where('clauses.id' => @current_project_clause_ids, 'clauserefs.subsection_id' => @selected_key_subsection.id)
    array_of_selected_clauses = selected_clauses.collect{|item6| item6.id}.uniq.sort

    @selected_specline_lines = Specline.includes(:clause => [:clausetitle, :guidenote, :clauseref => [:subsection]]).where(:project_id => @current_project.id, :clause_id => array_of_selected_clauses).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause, clause_line')                           

    
    #establish list of clausetypes to build tabulated view in show    
    selected_clause_ids = selected_clauses.collect{|item| item.id}.uniq.sort        
    clausetype_ids = Clausetype.joins(:clauserefs => :clauses).where('clauses.id' => selected_clause_ids).collect{|item1| item1.id}.uniq.sort 
    @clausetypes = Clausetype.where(:id => clausetype_ids)
    
    
    if params[:clausetype].blank?
     @current_clausetype = @clausetypes.first 
    else
     @current_clausetype = Clausetype.select('id').where(:id => params[:clausetype]).first 
    end
#end    
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @project }
        format.mobile
      end 
    end
  end

  def project_sections

    current_revision_render(@current_project)
    @project_sections = Section.joins(:subsections => [{:clauserefs => [{:clauses => :speclines}]}]).select('DISTINCT(sections.id)').where('speclines.project_id' => @current_project.id)    
  end

  def project_subsections

    current_revision_render(@current_project)
    @project_subsections = Subsection.joins(:clauserefs =>  [{:clauses => :speclines}]).select('DISTINCT subsections.id').where('speclines.project_id' => @current_project.id)   
    @selected_key_section = Section.where(:id => params[:section]).first   
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

    clause_line_array = Clauseref.joins(:clauses => :speclines).where('speclines.project_id' => @current_project.id).collect{|item2| item2.subsection_id}.sort.uniq 
    template_clause_line_array = Clauseref.joins(:clauses => :speclines).where('speclines.project_id' => @current_project_template.id).collect{|item2| item2.subsection_id}.sort 
     
    #clause_line_array = current_project_clauses.collect{|item2| item2.subsection_id}.sort       
    @current_project_subsections = Subsection.where(:id => clause_line_array)
  
    unused_clause_line_array = template_clause_line_array - clause_line_array
    @template_project_subsections = Subsection.where(:id => unused_clause_line_array)
  end
  
  
  ##POST
  def edit_subsections

      @current_project = Project.where('id = ? AND company_id =?', params[:project_id], current_user.company_id).first
    if @current_project.blank?
      redirect_to(:controller => "devise/sessions", :action => "destroy")
    else
    
subsection_list = Subsection.where(:id => params[:project_subsections]).collect{|i| i.id}
#clauses_array = Specline.where(:project_id => params[:project_id]).collect{|i| i.clause_id}
#subsection_array = Clause.where(:id=> clauses_array).collect{|i| i.subsection_id} 

subsection_array = Clause.joins(:speclines, :clauseref).where('speclines.project_id' => params[:project_id]).collect{|i| i.clauseref.subsection_id} 


subsections_to_add = subsection_list- subsection_array
if !subsections_to_add.blank?
	#clauses_to_add = Clause.where(:subsection_id => subsections_to_add).collect{|i| i.id}
	#speclines_to_add = Specline.where(:project_id => params[:template_id], :clause_id => clauses_to_add) 

speclines_to_add = Specline.joins(:clause => :clauseref).where(:project_id => params[:template_id], 'clauserefs.subsection_id' => subsections_to_add)

	speclines_to_add.each do |line_to_add|
		@new_specline = Specline.new(line_to_add.attributes.merge(:project_id => params[:project_id]))
		@new_specline.save
		@clause_change_record = 3
		record_new
	end                   
end

subsections_to_delete = subsection_array - subsection_list
if !subsections_to_delete.blank?

	#clauses_to_delete = Clause.where(:subsection_id => subsections_to_delete).collect{|i| i.id}
	#speclines_to_delete = Specline.where(:project_id => params[:project_id], :clause_id => clauses_to_delete)

  speclines_to_delete = Specline.joins(:clause => :clauseref).where(:project_id => params[:project_id], 'clauserefs.subsection_id' => subsections_to_delete)
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
	previous_changes_to_clause = Change.where(:project_id => params[:project_id], :clause_id => clauses_to_delete, :revision_id => @current_revision.id)
	if !previous_changes_to_clause.blank?
		previous_changes_to_clause.each do |previous_change|
		previous_change.clause_add_delete = 3
		previous_change.save
		end    
	end
end
     redirect_to(:controller => "projects", :action => "manage_subsections", :id => params[:project_id], :selected_template_id => params[:template_id])
end     
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
      
    current_project_and_templates(@current_project.id, current_user.company_id)
        
    if @current_project.project_status == 'Draft'
      @available_status_array = [['Draft', 'Draft'],['Preliminary', 'Preliminary'], ['Tender', 'Tender'], ['Contract', 'Contract'], ['As Built', 'As Built']]
    else
      @available_status_array = [['Preliminary', 'Preliminary'], ['Tender', 'Tender'], ['Contract', 'Contract'], ['As Built', 'As Built']]
    end
    
    #call to protected method that restablishes text to be shown for project revision status
    current_revision_render(@current_project)  
  end  
  

  def update_project
    @project = Project.find(params[:id])
                
      respond_to do |format|
        #if 
        @project.update_attributes(params[:project]) 
         if @project.project_status != 'Draft'
           check_rev_exists = Revision.where('project_id = ?', @project.id).first
            if check_rev_exists.rev.blank?
               check_rev_exists.rev = '-'
               check_rev_exists.save
            end
         end
        #end
      format.html { redirect_to(:controller => 'projects', :action => 'edit') }
      format.xml  { head :ok }
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