class PrintsController < ApplicationController

before_filter :require_user

layout "projects", :except => [:print_project]

  # GET /txt1s
  # GET /txt1s.xml
  #def index
  #  @projects = Project.all

  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.xml  { render :xml => @projects }
  #  end
 # end


  # GET /txt1s/1
  # GET /txt1s/1.xml
  def show

    #check user is owner of the project 
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first    
    if @current_project.blank?
      redirect_to log_out_path
    end

    #get all projects and current project template for view
    @projects = Project.where('company_id =?', current_user.company_id).order("code") 
    @current_project_template = Project.find(@current_project.parent_id)
    
    #call to protected method that restablishes text to be shown for project revision status
    #returns all_project_revisions
    current_revision_render(@current_project)
    
    #establish selected revision for project    
    if params[:revision].blank?
      last_revision_with_changes = @project_revisions.collect{|item| item.id}.last
      if last_revision_with_changes.blank?
        @selected_revision = Revision.where('project_id = ?', @current_project.id).last
      else
        @selected_revision = Revision.find(last_revision_with_changes)
      end
    else              
      @selected_revision = Revision.find(params[:revision])
    end
      
    #show if print with superseded
    #check if selected revision has been superseded, i.e. nest revision has been published
        
    if @current_project.project_status == 'Draft'
      
      @print_status_show = 'draft'
      
    else
          
      project_rev_array = @all_project_revisions.collect{|i| i.rev}

      total_revisions = project_rev_array.length        
      selected_revision = project_rev_array.index(@selected_revision.rev)    
      number_revisions_old = total_revisions - selected_revision - 1  
        
      if number_revisions_old > 1
        @print_status_show = 'superseded'
      end  
 
      if number_revisions_old == 1
        @print_status_show = 'issue'    
      end 

      if number_revisions_old == 0
        @print_status_show = 'not for issue'
      end 
    
    end
  
      #@last_project_revisions = Revision.where('project_id = ?', @current_project.id)
    #respond_to do |format|
    #  format.html # show.html.erb
    #  format.xml  { render :xml => @revision }
    #end

  end
  
  
  def print_project
    
    #check user is owner of the project 
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first    
    if @current_project.blank?
      redirect_to log_out_path
    end


    #establish selected revision for project
    if params[:revision].blank?
      @selected_revision = Revision.where(:project_id => params[:id]).last
    else
      @selected_revision = Revision.find(params[:revision])
    end
    #get list of all project revisions
    current_revision_render(@current_project)
 
    
    #watermark printing
    @superseded = []    
    @watermark = [] 
    if @current_project.project_status == 'Draft'
      
      @watermark[0] = 1 #show
      @superseded[0] = 2 #do not show
      
    else
          
      project_rev_array = @all_project_revisions.collect{|i| i.rev}

      total_revisions = project_rev_array.length        
      selected_revision = project_rev_array.index(@selected_revision.rev)    
      number_revisions_old = total_revisions - selected_revision - 1  
        
      if number_revisions_old > 1
        @superseded[0] = 1
        @watermark[0] = 2 #do not show
      end  
 
      if number_revisions_old == 1
        @watermark[0] = 2 #do not show
        @superseded[0] = 2 #do not show     
      end 

      if number_revisions_old == 0
        if params[:issue] == 'true'
          @watermark[0] = 1 #show
          @superseded[0] = 2 #do not show      
        else
          @watermark[0] = 2 #do not show
          @superseded[0] = 2 #do not show        
        end
      end     
    end


    ###update revision status of project if document is issued
    if @current_project.project_status != 'Draft'                
      current_revision = Revision.where(:project_id => @current_project.id).last
      if @selected_revision.rev == current_revision.rev       
        check_revision_use = Change.where(:project_id => params[:id], :revision_id => current_revision.id).first
        if !check_revision_use.blank?  #if there are revisions
          next_revision_ref = current_revision.rev.next
          @new_rev_record = Revision.new do |n|
            n.rev = next_revision_ref
            n.project_id = params[:id]
            n.user_id =  current_user.id
            n.date = Date.today
          end  
          @new_rev_record.save
        else
          if @selected_revision.rev == '-'
            next_revision_ref = 'a'
            @new_rev_record = Revision.new do |n|
              n.rev = next_revision_ref
              n.project_id = params[:id]
              n.user_id =  current_user.id
              n.date = Date.today
            end  
            @new_rev_record.save
          end  
        end                                      
      end
      @current_revision_rev = current_revision.rev.capitalize       
    end


    ######start of code specific to printing
    ###!!!!!!!!needs updating for variables passed from print view
    
    revision_clause_id_array = Change.select('DISTINCT clause_id').where(:project_id => @current_project.id, :revision_id => @selected_revision.id).collect{|item| item.clause_id}.sort    
    revision_subsection_id_array = Clauseref.joins(:clauses).where('clauses.id' => revision_clause_id_array).collect{|item| item.subsection_id}.sort.uniq    
    
    
    @revision_subsections = Subsection.where(:id => revision_subsection_id_array)

        @revision_prelim_subsections = Subsection.where(:id => revision_subsection_id_array, :section_id => 1)
    revision_prelim_subsection_id_array = @revision_prelim_subsections.collect{|item| item.id}.sort

    @current_clause_id_array = Specline.select('DISTINCT clause_id').where(:project_id => @current_project.id).collect{|item| item.clause_id}.sort       
    current_subsection_id_array = Clauseref.joins(:clauses).where('clauses.id' => @current_clause_id_array).collect{|item| item.subsection_id}.sort.uniq

    @current_subsections = Subsection.where(:id => current_subsection_id_array) 
    @current_prelim_subsections = Subsection.where(:id => current_subsection_id_array, :section_id => 1)
    @current_none_prelim_subsections = @current_subsections - @current_prelim_subsections

##prelim subsections

    @array_of_deleted_prelim_subsections = []
    @array_of_new_prelim_subsections = []
    @array_of_changed_prelim_subsections = []
        
    revision_prelim_subsection_id_array.each_with_index do |changed_subsection_id, i|
      
      array_of_subsection_clause_ids = Clause.joins(:clauseref).where('clauserefs.subsection_id' => changed_subsection_id).collect{|item| item.id}.sort.uniq
      
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
    
    array_prelim_subsection_clause_ids = Clause.joins(:clauseref).where('clauserefs.subsection_id' => changed_subsection.id).collect{|item| item.id}.sort.uniq
    
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
      
      array_of_subsection_clause_ids = Clause.joins(:clauseref).where('clauserefs.subsection_id'  => changed_subsection_id).collect{|item| item.id}.sort.uniq
      
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
    
    array_subsection_clause_ids = Clause.joins(:clauseref).where('clauserefs.subsection_id'  => changed_subsection.id).collect{|item| item.id}.sort.uniq
    
      changed_clauses = Change.select('DISTINCT clause_id').where(:project_id => @current_project.id, :clause_id => array_subsection_clause_ids, :revision_id => @selected_revision.id)			    
      changed_clauses.each_with_index do |changed_clause, i|
      
      add_check = Change.where(:event => 'new', :clause_add_delete => 2, :project_id => @current_project.id, :clause_id => changed_clause.clause_id, :revision_id => @selected_revision.id).first 
        if add_check.blank?
          deleted_check = Change.where(:event => 'deleted', :clause_add_delete => 2, :project_id => @current_project.id, :clause_id => changed_clause.clause_id, :revision_id => @selected_revision.id).first 
              if deleted_check.blank?
                @hash_of_changed_clauses[changed_subsection.id][i] = Clause.find(changed_clause.clause_id)              
              else
                @hash_of_deleted_clauses[changed_subsection.id][i] = Clause.find(changed_clause.clause_id)
              end
        else
          @hash_of_new_clauses[changed_subsection.id][i] = Clause.find(changed_clause.clause_id)
        end
      end
    end
        
   
    if @selected_revision.rev.blank?
      @print_revision_rev = 'n/a'
    else
      @print_revision_rev = @selected_revision.rev.capitalize
    end
    
    @company = Company.find(current_user.company_id) 
   
    #respond_to do |format|
    #  format.pdf  {render :layout => false}
      prawnto :filename => @current_project.code+"_rev_"+@print_revision_rev+".pdf", :prawn => {:page_size => "A4", :margin => [20.mm, 14.mm, 5.mm, 20.mm], :font => 'Times-Roman'}, :inline=>false     
    #end
  end

end