class PublicsController < ApplicationController

layout "publics"
         
  # GET /publics/1
  # GET /publics/1.xml
  def show 
#######need to add in company code in here and access control
      clause_reference = params[:clause_ref]

        
    @current_project = Project.where('code = ? AND company_id =?', params[:id], current_user.company_id).first
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
  if !params[:clause_ref].blank?
    
  section_ref = clause_reference[0]
  subsection_ref = clause_reference[1,2]    
    @selected_key_section = Section.select('id').where(:ref => section_ref).first
    @selected_key_subsection = Subsection.select('id, www').where(:ref => subsection_ref, :section_id => @selected_key_section.id).first
 else   
    if params[:section].blank?
      if params[:subsection].blank?     
          @selected_key_section = @project_sections.first
          @selected_key_subsection = Subsection.select('id, www').where(:id => current_project_subsection_ids, :section_id => @selected_key_section.id).first    
      else         
          @selected_key_subsection = Subsection.find(params[:subsection])
          @selected_key_section = Section.select('id').where(:id => @selected_key_subsection.section_id).first
      end
    else
          @selected_key_section = Section.select('id').where(:id => params[:section]).first
          @selected_key_subsection = Subsection.select('id, www').where(:id => current_project_subsection_ids, :section_id => @selected_key_section.id).first      
    end
 end
    @selected_subsections = Subsection.where(:id => current_project_subsection_ids, :section_id => @selected_key_section.id)

 if @selected_key_section.id != 1
  
    #get all speclines for selected subsection
    selected_clauses = Clause.joins(:clauseref).select('DISTINCT(clauses.id)').where('clauses.id' => @current_project_clause_ids, 'clauserefs.subsection_id' => @selected_key_subsection.id)
    array_of_selected_clauses = selected_clauses.collect{|item6| item6.id}.uniq.sort

    @selected_specline_lines = Specline.includes(:clause => [:clausetitle, :guide, :clauseref => [:subsection]]).where(:project_id => @current_project.id, :clause_id => array_of_selected_clauses).order('clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause, clause_line')                           

    
    #establish list of clausetypes to build tabulated view in show    
    selected_clause_ids = selected_clauses.collect{|item| item.id}.uniq.sort        
    clausetype_ids = Clausetype.joins(:clauserefs => :clauses).where('clauses.id' => selected_clause_ids).collect{|item1| item1.id}.uniq.sort 
    @clausetypes = Clausetype.where(:id => clausetype_ids)
    
    
    if params[:clausetype].blank?
     @current_clausetype = @clausetypes.first 
    else
     @current_clausetype = Clausetype.select('id').where(:id => params[:clausetype]).first 
    end
end    
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @project, :layout => 'publics' }
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
  
end