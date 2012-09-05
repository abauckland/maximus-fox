class RevisionsController < ApplicationController

before_filter :require_user

layout "projects"

  def show    

    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to(:controller => "devise/sessions", :action => "destroy")
    else
    
    @projects = Project.where('company_id =?', current_user.company_id).order("code") 
    @current_project_template = Project.find(@current_project.parent_id)
    
    #call to protected method that restablishes text to be shown for project revision status
    current_revision_render(@current_project)  
       
      if params[:revision].blank?
        #last_revision_with_changes = @project_revisions.collect{|item| item.id}.last
        #if last_revision_with_changes.blank?
        #  @selected_revision = Revision.where('project_id = ?', @current_project.id).last
        if @last_project_revision
          @selected_revision = @last_project_revision
        else
          @selected_revision = Revision.where('project_id = ?', @current_project.id).first
        end
      else              
        @selected_revision = Revision.find(params[:revision])
      end
    
    #@revision_clause_id_array = Change.where('project_id = ? AND revision_id = ?', @current_project.id, @selected_revision.id).collect{|item| item.clause_id}.sort   
    
    #revision_subsection_id_array = Clause.joins(:clauseref).where(:id => @revision_clause_id_array).collect{|i| i.clauseref.subsection_id}.sort.uniq
    
    revision_subsection_id_array = Clauseref.joins(:clauses => [:changes]).where('changes.project_id' => @current_project.id, 'changes.revision_id' => @selected_revision.id).collect{|i| i.subsection_id}.sort.uniq
    
    
    
    @revision_prelim_subsections = Subsection.where(:id => revision_subsection_id_array, :section_id => 1)
    revision_prelim_subsection_id_array = @revision_prelim_subsections.collect{|item| item.id}.sort
    
      @first_prelim_susbsection = @revision_prelim_subsections.first
    @revision_subsections = Subsection.where(:id => revision_subsection_id_array)
    @revision_none_prelim_subsections = @revision_subsections - @revision_prelim_subsections

##prelim subsections

    @array_of_deleted_prelim_subsections = []
    @array_of_new_prelim_subsections = []
    @array_of_changed_prelim_subsections = []
        
    revision_prelim_subsection_id_array.each_with_index do |changed_subsection_id, i|
     
      array_of_subsection_clause_ids = Clause.joins(:clauseref).where('clauserefs.subsection_id' => changed_subsection_id).collect{|item| item.id}.sort

      
      new_subsections = Change.where(:event => 'new', :clause_add_delete => 3, :project_id => @current_project.id, :clause_id => array_of_subsection_clause_ids, :revision_id => @selected_revision.id)#.first 
      if new_subsections.blank?
          deleted_subsections = Change.where(:event => 'deleted', :clause_add_delete => 3, :project_id => @current_project.id, :clause_id => array_of_subsection_clause_ids, :revision_id => @selected_revision.id)#.first 
          if deleted_subsections.blank?
            @array_of_changed_prelim_subsections[i] = Subsection.find(changed_subsection_id)
          else
            @array_of_deleted_prelim_subsections[i] = Subsection.find(changed_subsection_id)
          end              
      else
        @array_of_new_prelim_subsections[i] = Subsection.find(changed_subsection_id)
      end
    end

    @array_of_new_prelim_subsections_compacted = @array_of_new_prelim_subsections.compact
    @array_of_deleted_prelim_subsections_compacted = @array_of_deleted_prelim_subsections.compact
    @array_of_changed_prelim_subsections_compacted = @array_of_changed_prelim_subsections.compact
   
    ##establish list of changed clauses for each changed subsection
    @hash_of_deleted_prelim_clauses ={}
    @hash_of_new_prelim_clauses = {}
    @hash_of_changed_prelim_clauses = {}
        
    @array_of_changed_prelim_subsections_compacted.each do |changed_subsection|
    
    @hash_of_deleted_prelim_clauses[changed_subsection.id] = []
    @hash_of_new_prelim_clauses[changed_subsection.id] = []
    @hash_of_changed_prelim_clauses[changed_subsection.id] = []
    
    array_prelim_subsection_clause_ids = Clause.joins(:clauseref).where('clauserefs.subsection_id' => changed_subsection.id).collect{|item| item.id}.sort
 
    
      changed_clauses = Change.select('DISTINCT clause_id').where(:project_id => @current_project.id, :clause_id => array_prelim_subsection_clause_ids, :revision_id => @selected_revision.id)			    
      changed_clauses.each_with_index do |changed_clause, i|
      
      add_check = Change.where(:event => 'new', :clause_add_delete => 2, :project_id => @current_project.id, :clause_id => changed_clause.clause_id, :revision_id => @selected_revision.id).first 
        if add_check.blank?
          deleted_check = Change.where(:event => 'deleted', :clause_add_delete => 2, :project_id => @current_project.id, :clause_id => changed_clause.clause_id, :revision_id => @selected_revision.id).first 
              if deleted_check.blank?
                @hash_of_changed_prelim_clauses[changed_subsection.id][i] = Clause.find(changed_clause.clause_id)              
              else
                @hash_of_deleted_prelim_clauses[changed_subsection.id][i] = Clause.find(changed_clause.clause_id)
              end
        else
          @hash_of_new_prelim_clauses[changed_subsection.id][i] = Clause.find(changed_clause.clause_id)
        end
      end
    end


##non prelim subsections
    @array_of_deleted_subsections = []
    @array_of_new_subsections = []
    @array_of_changed_subsections = []
        
    revision_subsection_id_array.each_with_index do |changed_subsection_id, i|
      
    array_of_subsection_clause_ids = Clause.joins(:clauseref).where('clauserefs.subsection_id' => changed_subsection_id).collect{|item| item.id}.sort
       
      new_subsections = Change.where(:event => 'new', :clause_add_delete => 3, :project_id => @current_project.id, :clause_id => array_of_subsection_clause_ids, :revision_id => @selected_revision.id)#.first 
      if new_subsections.blank?
          deleted_subsections = Change.where(:event => 'deleted', :clause_add_delete => 3, :project_id => @current_project.id, :clause_id => array_of_subsection_clause_ids, :revision_id => @selected_revision.id)#.first 
          if deleted_subsections.blank?
            @array_of_changed_subsections[i] = Subsection.find(changed_subsection_id)
          else
            @array_of_deleted_subsections[i] = Subsection.find(changed_subsection_id)
          end              
      else
        @array_of_new_subsections[i] = Subsection.find(changed_subsection_id)
      end
    end

    @array_of_new_subsections_compacted = @array_of_new_subsections.compact
    @array_of_deleted_subsections_compacted = @array_of_deleted_subsections.compact
    @array_of_changed_subsections_compacted = @array_of_changed_subsections.compact
   
    ##establish list of changed clauses for each changed subsection
    @hash_of_deleted_clauses ={}
    @hash_of_new_clauses = {}
    @hash_of_changed_clauses = {}
        
    @array_of_changed_subsections_compacted.each do |changed_subsection|
    
    @hash_of_deleted_clauses[changed_subsection.id] = []
    @hash_of_new_clauses[changed_subsection.id] = []
    @hash_of_changed_clauses[changed_subsection.id] = []
    
    array_subsection_clause_ids = Clause.joins(:clauseref).where('clauserefs.subsection_id' => changed_subsection.id).collect{|item| item.id}.sort
    
      changed_clauses = Change.select('DISTINCT clause_id').where(:project_id => @current_project.id, :clause_id => array_subsection_clause_ids, :revision_id => @selected_revision.id)			    
      changed_clauses.each_with_index do |changed_clause, i|
      
      add_check = Change.where(:event => 'new', :clause_add_delete => 2, :project_id => @current_project.id, :clause_id => changed_clause.clause_id, :revision_id => @selected_revision.id).first 
        if add_check.blank?
          deleted_check = Change.where(:event => 'deleted', :clause_add_delete => 2, :project_id => @current_project.id, :clause_id => changed_clause.clause_id, :revision_id => @selected_revision.id).first 
              if deleted_check.blank?
                @hash_of_changed_clauses[changed_subsection.id][i] = Clause.where(:id => changed_clause.clause_id).first              
              else
                @hash_of_deleted_clauses[changed_subsection.id][i] = Clause.where(:id => changed_clause.clause_id).first
              end
        else
          @hash_of_new_clauses[changed_subsection.id][i] = Clause.where(:id => changed_clause.clause_id).first
        end
      end
    end
  end



    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @revision }
    end
  end


  def clause_change_info
      @clause_change_info = Change.select('user.email, created_at').includes(:user).where('project_id = ? AND clause_id = ? AND revision_id =?', params[:id], params[:clause_id], params[:rev_id]).last
      @clause_id = params[:clause_id]
      respond_to do |format|
        format.js   { render :clause_change_info, :layout => false }
      end
  end

  def line_change_info
      @line_change_info = Change.select('user.email, created_at').includes(:user).where(:id => params[:id]).first
      @line_id = params[:id]
      
      respond_to do |format|
        format.js   { render :line_change_info, :layout => false }
      end
  end

  def print_setting
    @change = Change.find(params[:id])
    if @change.print_change == false
      @change.print_change = true
      @current_rev_line_class = '_strike'
      @next_rev_line_class = ''
      @rev_print_image = 'noprint_rev.png' 
    else
      @change.print_change = false
      @current_rev_line_class = ''
      @next_rev_line_class = '_strike'
      @rev_print_image = 'print_rev.png'
    end
    @change.save
        
    respond_to do |format|
      #format.html { redirect_to (:controller => "revisions", :action => "select_project", :id => @change.project_id, :subsection => @change.clause.subsection_id)}
      #format.xml  { head :ok }
      format.js   { render :layout => false }
    end    
  end

end