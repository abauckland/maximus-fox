class ExportsController < ActionController::Base

  def keynote_export    
      if params[:cad_product] == 'revit'
        revit_keynote_export(params[:id])
      end 

      if params[:cad_product] == 'bentley'
        bentley_keynote_export(params[:id])      
      end 

      if params[:cad_product] == 'cadimage'
        cadimage_keynote_export(params[:id])      
      end              
  end
  
  
  
  def revit_keynote_export(project_id)
    
    @current_project = Project.where(:id => params[:id]).first 
    ##!!!!!!need to sort out how it renders - i.e. file dounloads and how to file with correct name and extension  
    filename = @current_project.code + " specright_keynote"   
    @bim_revit_export = CSV.generate(:col_sep => "\t") do |csv|   
   
      #for each section 
      current_project_sections = Section.joins(:subsections => [:clauserefs => [:clauses => :speclines]]).where('speclines.project_id' => @current_project.id).order('id').uniq        
      current_project_sections.each_with_index do |section, i|
        #project section    
        csv << [section.ref, section.text]
        #for each subsection     
        current_project_subsections = Subsection.joins(:clauserefs => [:clauses => :speclines]).includes(:section).where('speclines.project_id' => @current_project.id, :section_id => section.id).order('id').uniq         
        current_project_subsections.each_with_index do |subsection, n|
          #project subsection
          csv << [subsection.subsection_code, subsection.text, subsection.section.ref] 
          #for each clause
          current_project_clauses = Clause.joins(:speclines).includes(:clausetitle, :clauseref => [:subsection => :section]).where('speclines.project_id' => @current_project.id, 'clauserefs.subsection_id' => subsection.id, 'clauserefs.clausetype_id' => [2..4]).order('clauserefs.subsection_id, clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause').uniq        
          current_project_clauses.each_with_index do |clause, m|
            #project clauses 
            csv << [clause.clause_code, clause.clausetitle.text, clause.clauseref.subsection.subsection_code] 
          end  
        end 
      end
    end  
    send_data @bim_revit_export, :type => 'text/plain', :disposition => 'attachment; filename=#{filename}.txt'      
  end


  def bentley_keynote_export(project_id)
    
    @current_project = Project.where(:id => params[:id]).first 
    filename = @current_project.code + " specright_keynote"   
    @bim_bentley_export = CSV.generate do |csv|  
      
      #for each section
      current_project_sections = Section.joins(:subsections => [:clauserefs => [:clauses => :speclines]]).where('speclines.project_id' => @current_project.id).order('id').uniq        
      current_project_sections.each_with_index do |section, i|
        #project section
        csv << [section.ref << ' ' << section.text]
        #for each subsection
        current_project_subsections = Subsection.joins(:clauserefs => [:clauses => :speclines]).includes(:section).where('speclines.project_id' => @current_project.id, :section_id => section.id).order('id').uniq         
        current_project_subsections.each_with_index do |subsection, n|
          #project subsection
          csv << [subsection.subsection_code << '*' << subsection.text]
          #for each clause
          current_project_clauses = Clause.joins(:speclines).includes(:clausetitle, :clauseref => [:subsection => :section]).where('speclines.project_id' => @current_project.id, 'clauserefs.subsection_id' => subsection.id, 'clauserefs.clausetype_id' => [2..4]).order('clauserefs.subsection_id, clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause').uniq        
          current_project_clauses.each_with_index do |clause, m|          
            #project clauses
            csv << [clause.clause_code << '*' << clause.clausetitle.text]
          end  
        end
        csv << []        
      end
    end  
    send_data @bim_bentley_export, :type => 'text/plain', :disposition => 'attachment; filename=#{filename}.spc'      
  end
  
  def cadimage_keynote_export(project_id)
    
    @current_project = Project.where(:id => params[:id]).first 
    filename = @current_project.code + " specright_keynote"   
    @bim_bentley_export = CSV.generate(:col_sep => "\t") do |csv|
      
      #headers
      #set up for columns, unique identifier column to be set to 'Create Unique IDS'
      csv << ['category', 'ignore', 'Keynote Key', 'Short Description', 'Long Description', 'Specfication Ref.', 'Time Stamp']  
      
      #for each section
      current_project_subsections = Subsection.joins(:clauserefs => [:clauses => :speclines]).includes(:section).where('speclines.project_id' => @current_project.id).order('id').uniq         
      current_project_subsections.each_with_index do |subsection, n|
        #project subsection
        csv << [subsection.subsection_code, '', subsection.subsection_code, subsection.text]
        #for each clause
        current_project_clauses = Clause.joins(:speclines).includes(:clausetitle, :clauseref => [:subsection => :section]).where('speclines.project_id' => @current_project.id, 'clauserefs.subsection_id' => subsection.id, 'clauserefs.clausetype_id' => [2..4]).order('clauserefs.subsection_id, clauserefs.clausetype_id, clauserefs.clause, clauserefs.subclause').uniq        
        current_project_clauses.each_with_index do |clause, m|          
          #project clauses
          csv << [subsection.subsection_code, '', clause.clause_code, clause.clausetitle.text]
        end  
      end      
    end  
    send_data @bim_bentley_export, :type => 'text/plain', :disposition => 'attachment; filename=#{filename}.txt'      
  end
    
end