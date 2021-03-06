class ClausesController < ApplicationController

before_filter :require_user

layout "projects"


#new clause create code
#need to set up route and carry over variables
  def new
    
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end    

    @clause = Clause.new
    clausetitle = @clause.build_clausetitle
    clauseref = @clause.build_clauseref
    
    @current_subsection = Subsection.where(:id => params[:subsection]).first
#    @projects = Project.where(:company_id => [1, current_user.company_id]).order("company_id, code") 

    
  #  @clone_clauses = Clause.includes(:speclines, :clausetitle, :clauseref => [:subsection => [:section]]).where('speclines.project_id' => @current_project.id).order('clauserefs.subsection_id', 'clauserefs.clausetype_id', 'clauserefs.clause', 'clauserefs.subclause')
  #  @current_clone_clause = @clone_clauses.first
  
  end

  def create

    @current_project = Project.where('id = ? AND company_id =?', params[:project_id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end 
    
    @current_subsection = Subsection.where(:id => params[:clause][:clauseref_attributes][:subsection_id]).first
    array_current_project_clauses = Specline.where('project_id =? AND clause_line = ?', @current_project.id, 0).collect{|item| item.clause_id}.uniq   
    @projects = Project.where(:company_id => [1, current_user.company_id]).order("company_id, code") 
    @current_project_clauses = Clause.includes(:clauseref).where(:id => array_current_project_clauses).order('clauserefs.subsection_id, clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause')
    @clause = Clause.new(params[:clause])


    @clone_clauses = Clause.includes(:speclines, :clausetitle, :clauseref => [:subsection => [:section]]).where('speclines.project_id' => @current_project.id).order('clauserefs.subsection_id', 'clauserefs.clausetype_id', 'clauserefs.clause', 'clauserefs.subclause')
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
#      clausetitle_check = Specline.joins(:clause => [:clauseref, :clausetitle]).where(:project_id => @current_project, 'clauserefs.subsection_id' => params[:clause][:clauseref_attributes][:subsection_id], 'clausetitles.text' => params[:clause][:title_text]).first

      #clausetitle_check = Clausetitle.where(:text => params[:clause][:title_text]).first
#      if !clausetitle_check.blank?
#        flash.now[:error] = 'A clause with the same title already exists in this Work Section'        
#        respond_to do |format|
#          format.html { render :action => "new"}
#          format.xml  { render :xml => @clause.errors, :status => :unprocessable_entity }
#        end 
        
      #if clausetitle_id and clauseref_id are in use in clause do not create new clause record but usse existing to create speclines  
                  
#      else    

          if @clause.save
            #create title line
              @new_specline = Specline.new do |n|
                n.project_id = @current_project.id
                n.clause_id = @clause.id
                n.clause_line = 0
                n.linetype_id = 1
              end
              @new_specline.save
              @clause_change_record = 2      
              record_new
            #get information on content to be created
                clausetype_id = params[:clause][:clauseref_attributes][:full_clause_ref][0,1]
                
                case clausetype_id
                  when '1' ;  @linetype_id = 7
                  when '2' ;  @linetype_id = 8
                  when '3' ;  @linetype_id = 8
                  when '4' ;  @linetype_id = 8
                  when '5' ;  @linetype_id = 8
                  when '6' ;  @linetype_id = 7
                  when '7' ;  @linetype_id = 7
                  when '8' ;  @linetype_id = 7
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
 
              clone_speclines = Specline.where('clause_id = ? AND project_id = ? AND clause_line > ?', params[:clone_clause_id], params[:clone_template_id], 0)         
              clone_speclines.each do |clone_line|
                @new_specline = Specline.new(clone_line.attributes.merge({:project_id => @current_project.id, :clause_id => @clause.id}))      
                @new_specline.save
                @clause_change_record = 2
                record_new
              end            
            end
         
            redirect_to(:controller => "speclines", :action => "manage_clauses", :id => @current_project.id, :project_id => @current_project.id, :subsection_id => @current_subsection.id)
            #render to manage clauses page 
            #format.html { render :action => "new"}
          else
          respond_to do |format|
            format.html { render :action => "new"}
            format.xml  { render :xml => @clause.errors, :status => :unprocessable_entity }
          end
        end 
#      end
    end
  end

  def new_clone_project_list
    @projects = Project.where(:company_id => [1, current_user.company_id]).order("company_id, code")   
  end
  
  def new_clone_subsection_list
    clone_subsection_ids = Subsection.joins(:clauserefs => [:clauses => :speclines]).where('speclines.project_id' => params[:id]).collect{|i| i.id}.uniq
    @clone_subsections = Subsection.includes(:section).where(:id => clone_subsection_ids)
  end
  
  def new_clone_clause_list
    clone_clause_ids = Clause.joins(:clauseref, :speclines).where('speclines.project_id' => params[:id], 'clauserefs.subsection_id' => params[:subsection]).collect{|i| i.id}.uniq
    @clone_clauses = Clause.includes(:clausetitle, :clauseref => [:subsection => :section]).where(:id => clone_clause_ids).order('clauserefs.subsection_id', 'clauserefs.clausetype_id', 'clauserefs.clause', 'clauserefs.subclause')    
  end
    
  

#end of class
end