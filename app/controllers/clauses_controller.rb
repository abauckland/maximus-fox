class ClausesController < ApplicationController

before_filter :require_user

layout "projects"


#new clause create code
#need to set up route and carry over variables
  def new
    
    @current_project = Project.where('id = ? AND company_id =?', params[:project_id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end    

    @clause = Clause.new
    clausetitle = @clause.build_clausetitle
    clauseref = @clause.build_clauseref
    
    @current_subsection = Subsection.where(:id => params[:subsection]).first
    @selected_specline_id = params[:id]
    @projects = Project.where(:company_id => [1, current_user.company_id]).order("company_id, code") 

    
    clone_clause_ids = Specline.where(:project_id => @current_project.id).collect{|i| i.clause_id}.uniq
    @clone_clauses = Clause.joins(:clauseref, :clausetitle).where(:id => clone_clause_ids).order('clauserefs.subsection_id', 'clauserefs.clausetype_id', 'clauserefs.clause', 'clauserefs.subclause')
    @current_clone_clause = @clone_clauses.first
  
  end

  def create

    @current_project = Project.where('id = ? AND company_id =?', params[:clause][:project_id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end 
    
    @current_subsection = Subsection.where(:id => params[:clause][:clauseref_attributes][:subsection_id]).first
    @selected_specline_id = params[:specline_id]
    array_current_project_clauses = Specline.where('project_id =? AND clause_line = ?', @current_project.id, 0).collect{|item| item.clause_id}.uniq   
    @projects = Project.where(:company_id => [1, current_user.company_id]).order("company_id, code") 
    @current_project_clauses = Clause.includes(:clauseref).where(:id => array_current_project_clauses).order('clauserefs.subsection_id, clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause')
    @clause = Clause.new(params[:clause])

    clone_clause_ids = Specline.where(:project_id => @current_project.id).collect{|i| i.clause_id}.uniq
    @clone_clauses = Clause.joins(:clauseref, :clausetitle).where(:id => clone_clause_ids).order('clauserefs.subsection_id', 'clauserefs.clausetype_id', 'clauserefs.clause', 'clauserefs.subclause')
    @current_clone_clause = Clause.first#@clone_clauses.first


    current_clauseref = Specline.joins(:clause => :clauseref).where(:project_id => @current_project, 'clauserefs.subsection_id' => params[:clause][:clauseref_attributes][:subsection_id], 'clauserefs.clausetype_id' => params[:clause][:clauseref_attributes][:full_clause_ref][0,1], 'clauserefs.clause' => params[:clause][:clauseref_attributes][:full_clause_ref][1,2], 'clauserefs.subclause' => params[:clause][:clauseref_attributes][:full_clause_ref][3,1]).first
    if !current_clauseref.blank?
      flash.now[:error] = 'A clause with the same reference already exists in this Work Section'        
      respond_to do |format|
        format.html { render :action => "new"}
        format.xml  { render :xml => @clause.errors, :status => :unprocessable_entity }
      end
    else
      #check not case sensitive
      clausetitle_check = Specline.joins(:clause => [:clauseref, :clausetitle]).where(:project_id => @current_project, 'clauserefs.subsection_id' => params[:clause][:clauseref_attributes][:subsection_id], 'clausetitles.text' => params[:clause][:title_text]).first

      #clausetitle_check = Clausetitle.where(:text => params[:clause][:title_text]).first
      if !clausetitle_check.blank?
        flash.now[:error] = 'A clause with the same title already exists in this Work Section'        
        respond_to do |format|
          format.html { render :action => "new"}
          format.xml  { render :xml => @clause.errors, :status => :unprocessable_entity }
        end 
        
      #if clausetitle_id and clauseref_id are in use in clause do not create new clause record but usse existing to create speclines  
                  
      else    
        respond_to do |format|
          if @clause.save
            #get information on content to be created
                clausetype_id = params[:clause][:clauseref_attributes][:full_clause_ref][0,1]
                
                case clausetype_id
                  when '1' ;  @linetype_id = 7
                  when '2' ;  @linetype_id = 6
                  when '3' ;  @linetype_id = 5
                  when '4' ;  @linetype_id = 6
                  when '5' ;  @linetype_id = 7
                  when '6' ;  @linetype_id = 7
                end
          
            if params[:clause_content] == 'blank_content'
              @new_specline = Specline.new do |n|
                n.project_id = @current_project.id
                n.clause_id = @clause.id
                n.clause_line = 1
                n.linetype_id = @linetype_id
              end
              @new_specline.save
              @clause_change_record = 2      
              record_new
            else  
              clone_speclines = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?', params[:clone_clause], params[:clone_project], 0)
           
              clone_speclines.each do |clone_line|
                @new_specline = Specline.new(clone_line.attributes.merge({:project_id => project_id, :clause_id => @clause.id}))      
                @new_specline.save
                @clause_change_record = 2
                record_new
              end            
            end
            
            #render to manage clauses page 
            format.html { render :action => "new"}
          else
            format.html { render :action => "new"}
            format.xml  { render :xml => @clause.errors, :status => :unprocessable_entity }
          end
        end 
      end
    end
  end

  def update_clause_select
  
    clone_clause_ids = Specline.where(:project_id => params[:id]).collect{|i| i.clause_id}.uniq
    @clone_clauses = Clause.joins(:clauseref, :clausetitle).where(:id => clone_clause_ids).order('clauserefs.subsection_id', 'clauserefs.clausetype_id', 'clauserefs.clause', 'clauserefs.subclause')
    @current_clone_clause = @clone_clauses.first

  end

#end of class
end