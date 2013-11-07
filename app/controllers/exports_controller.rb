class ExportsController < ActionController::Base



  def revit_keynote_export
    @current_project = Project.where(:id => params[:id]).first
 
##!!!!!!need to sort out how it renders - i.e. file dounloads and how to file with correct name and extension 
 
 filename = @current_project.code + "specright_keynote.txt"   
 @bim_revit_export = CSV.generate(:col_sep => "\t") do |csv|   
   
    #getall sections for project
    current_project_sections = Section.joins(:subsections => [:clauserefs => [:clauses => :speclines]]).where('speclines.project_id' => @current_project.id).order('id').uniq        
     
    #for each section
    
    #line_no = 0
    
    current_project_sections.each_with_index do |section, i|
      #getall subsections for project
      
     # line_no = line_no + 1
      #line[line_no] = [section.ref, section.title]     
      
      csv << [section.ref, section.text, 'test'] 
      
      
      current_project_subsections = Subsection.joins(:clauserefs => [:clauses => :speclines]).includes(:section).where('speclines.project_id' => @current_project.id, :section_id => section.id).order('id').uniq         
      current_project_subsections.each_with_index do |subsection, n|
        
       # line_no = line_no + 1
       # line[line_no] = [subsection.subsection_code, subsection.text, subsection.section.ref]   
       csv << [subsection.subsection_code, subsection.text, subsection.section.ref] 
        
        current_project_clauses = Clause.joins(:speclines).includes(:clausetitle, :clauseref => [:subsection => :section]).where('speclines.project_id' => @current_project.id, 'clauserefs.subsection_id' => subsection.id, 'clauserefs.clausetype_id' => [2..4]).order('clauserefs.subsection_id, clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause').uniq        
        current_project_clauses.each_with_index do |clause, m|
          
         # line_no = line_no + 1
         # line[line_no] = [clause.clause_code, clause.clausetitle, clause.clauseref.subsection.subsection_code] 
         csv << [clause.clause_code, clause.clausetitle.text, clause.clauseref.subsection.subsection_code] 
        end  
      end 
    end

  end
  
    
    respond_to do |format|
      format.txt  { send_data @bim_revit_export, {:filename => "??.txt"} }
    end    
  
end
    
end