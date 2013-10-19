class RevisionsController < ApplicationController

before_filter :require_user
before_filter :check_project_ownership, :except => [:show_rev_tab_content, :clause_change_info, :line_change_info, :print_setting]

layout "projects"

  def show    
    
    @projects = Project.where('company_id =?', current_user.company_id).order("code") 
    @current_project_template = Project.find(@current_project.parent_id)
    
    #call to protected method that restablishes text to be shown for project revision status
    current_revision_render(@current_project)  
       
      if params[:revision].blank?
        if @last_project_revision
          @selected_revision = @last_project_revision
        else
          @selected_revision = Revision.where('project_id = ?', @current_project.id).first
        end
      else              
        @selected_revision = Revision.find(params[:revision])
      end

    #tab menu - estabished list of subsections with revisions    
    revision_subsections = Clauseref.joins(:clauses => [:changes]).where('changes.project_id' => @current_project.id, 'changes.revision_id' => @selected_revision.id)
    revision_subsection_id_array = revision_subsections.collect{|i| i.subsection_id}.sort.uniq
       
    @revision_prelim_subsections = Subsection.where(:id => revision_subsection_id_array, :section_id => 1)
    revision_prelim_subsection_id_array = @revision_prelim_subsections.collect{|item| item.id}.sort
    
    @first_prelim_susbsection = @revision_prelim_subsections.first
    @revision_subsections = Subsection.where(:id => revision_subsection_id_array)
    @revision_none_prelim_subsections = @revision_subsections - @revision_prelim_subsections


    ##prelim subsections
    if @revision_prelim_subsections
      #get list of prelim subsections in project where changes have been made   
      prelim_subsection_change_data(@current_project, @revision_prelim_subsections, @selected_revision)
          
    ##non prelim subsections
    else

      @revision_subsection = @revision_subsections.first.id
      
      
      #establish if subsection is new or has been deleted      
      subsection_change_data(@current_project, @revision_subsection, @selected_revision)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @revision }
    end
  end




  def show_prelim_tab_content

    @current_project = Project.find(params[:id])
    @selected_revision = Revision.find(params[:revision_id])

      revision_subsections = Clauseref.joins(:clauses => [:changes]).where('changes.project_id' => @current_project.id, 'changes.revision_id' => @selected_revision.id)
      revision_subsection_id_array = revision_subsections.collect{|i| i.subsection_id}.sort.uniq
       
      @revision_prelim_subsections = Subsection.where(:id => revision_subsection_id_array, :section_id => 1)

      prelim_subsection_change_data(@current_project, @revision_prelim_subsections, @selected_revision)

    respond_to do |format|
        format.js  { render :show_rev_tab_content_prelim, :layout => false } 
    end    
  end




  def show_rev_tab_content

    @current_project = Project.find(params[:id])
    @selected_revision = Revision.find(params[:revision_id])

    @revision_subsection = Subsection.find(params[:subsection_id])  
    #establish if subsection is new or has been deleted      
    subsection_change_data(@current_project, @revision_subsection, @selected_revision)

    respond_to do |format|
        
        format.js  { render :show_rev_tab_content, :layout => false } 
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

protected
def check_project_ownership
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end
end


def prelim_subsection_change_data(current_project, revision_prelim_subsections, selected_revision)

        @array_of_deleted_prelim_subsections = []
        @array_of_new_prelim_subsections = []
        @array_of_changed_prelim_subsections = []

        #check if prelim subsection is new, added or changed
      revision_prelim_subsections.each_with_index do |subsection, i|
         
        new_subsections = Change.joins(:clause => :clauseref).where('clauserefs.subsection_id' => subsection.id, :event => 'new', :clause_add_delete => 3, :project_id => current_project.id, :revision_id => selected_revision.id)
        if new_subsections.blank?
            deleted_subsections = Change.joins(:clause => :clauseref).where('clauserefs.subsection_id' => subsection.id, :event => 'deleted', :clause_add_delete => 3, :project_id => current_project.id, :revision_id => selected_revision.id)
            if deleted_subsections.blank?
              @array_of_changed_prelim_subsections[i] = subsection
            else
              @array_of_deleted_prelim_subsections[i] = subsection
            end              
        else
          @array_of_new_prelim_subsections[i] = subsection
        end
        @array_of_new_prelim_subsections_compacted = @array_of_new_prelim_subsections.compact
        @array_of_deleted_prelim_subsections_compacted = @array_of_deleted_prelim_subsections.compact
        @array_of_changed_prelim_subsections_compacted = @array_of_changed_prelim_subsections.compact
   
        ##establish list of changed clauses for each changed prelim subsection
        @hash_of_deleted_prelim_clauses ={}
        @hash_of_new_prelim_clauses = {}
        @hash_of_changed_prelim_clauses = {}

            
        @array_of_changed_prelim_subsections_compacted.each do |changed_subsection|  

          @hash_of_deleted_prelim_clauses[changed_subsection.id] = []
          @hash_of_new_prelim_clauses[changed_subsection.id] = []
          @hash_of_changed_prelim_clauses[changed_subsection.id] = []
    

          all_clauses = Change.joins(:clause => :clauseref).where('clauserefs.subsection_id' => changed_subsection.id, :project_id => current_project.id, :revision_id => selected_revision.id).collect{|x| x.clause_id}.uniq.sort
          changed_clauses = Clause.where(:id => all_clauses)
             
          changed_clauses.each_with_index do |changed_clause, n|
      
            add_check = Change.where(:event => 'new', :clause_add_delete => 2, :project_id => current_project.id, :clause_id => changed_clause.id, :revision_id => selected_revision.id).first 
            if add_check.blank?
              deleted_check = Change.where(:event => 'deleted', :clause_add_delete => 2, :project_id => current_project.id, :clause_id => changed_clause.id, :revision_id => selected_revision.id).first 
              if deleted_check.blank?
                @hash_of_changed_prelim_clauses[changed_subsection.id][n] = changed_clause             
              else
                @hash_of_deleted_prelim_clauses[changed_subsection.id][n] = changed_clause
              end
            else
              @hash_of_new_prelim_clauses[changed_subsection.id][n] = changed_clause
            end
          end
        end     
      end      
  
end


def subsection_change_data(current_project, revision_subsection, selected_revision)
      subsection_change = Change.joins(:clause => :clauseref).where(:clause_add_delete => 3, :project_id => current_project.id, 'clauserefs.subsection_id' => revision_subsection.id, :revision_id => selected_revision.id).first 
      
      if subsection_change
        if subsection_change.event == 'new'
          @new_subsections = revision_subsection
        end
        if subsection_change.event == 'deleted'
          @deleted_subsections = revision_subsection
        end
      else

      #check status of clause within changed subsection   
        all_clauses = Change.joins(:clause => :clauseref).where('clauserefs.subsection_id' => revision_subsection.id, :project_id => current_project.id, :revision_id => selected_revision.id).collect{|i| i.clause_id}.uniq.sort
        changed_clauses = Clause.where(:id => all_clauses)

          @array_of_changed_clauses = []
          @array_of_deleted_clauses = []
          @array_of_new_clauses = []
      
        changed_clauses.each_with_index do |changed_clause, i|
           
          add_check = Change.where(:event => 'new', :clause_add_delete => 2, :project_id => current_project.id, :clause_id => changed_clause.id, :revision_id => selected_revision.id).first 
          if add_check.blank?
            deleted_check = Change.where(:event => 'deleted', :clause_add_delete => 2, :project_id => current_project.id, :clause_id => changed_clause.id, :revision_id => selected_revision.id).first 
            if deleted_check.blank?
              @array_of_changed_clauses[i] = changed_clause              
            else
              @array_of_deleted_clauses[i] = changed_clause
            end
          else
            @array_of_new_clauses[i] = changed_clause
          end
        end
      end

      @array_of_changed_clauses = @array_of_changed_clauses.compact
      @array_of_deleted_clauses = @array_of_deleted_clauses.compact
      @array_of_new_clauses = @array_of_new_clauses.compact  
end


end