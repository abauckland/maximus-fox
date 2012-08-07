class GuidenotesController < ApplicationController

before_filter :require_user
layout "guides"

  def index
    @guides = Guide.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @guides }
    end
  end


  def show
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    else
    
    array_subsection_guides = Clause.where('guide_id > ?', 0).collect{|i| i.subsection_id}.sort.uniq
    array_section_guides = Subsection.where(:id => array_subsection_guides).collect{|i| i.section_id}.sort.uniq
    
    
    if params[:subsection_id].blank?
      if params[:section_id].blank?
        @selected_guide_section = Section.where(:id => array_section_guides).first
      else
        @selected_guide_section = Section.where('id =?', params[:section_id]).first
      end

  ####if first subsection in table is not in list of subsetions on offer      
        possible_subsections = Subsection.where('section_id =?', @selected_guide_section.id).collect{|i| i.id}
        array_guides_exist = possible_subsections & array_subsection_guides
        @selected_guide_subsection = Subsection.where(:id => array_guides_exist).first
    else
      @selected_guide_subsection = Subsection.where('id =?', params[:subsection_id]).first
      @selected_guide_section = Section.select('id').where('id =?', @selected_guide_subsection.section_id).first 
    end  
    
    @guide_sections = Section.where(:id => array_section_guides)    
    array_guide_subsections_selected = Subsection.where(:section_id => @selected_guide_section.id).collect{|i| i.id}.sort
    
    array_guides_exist = array_guide_subsections_selected & array_subsection_guides
    @guide_subsections = Subsection.where(:id => array_guides_exist)
        
    @applicable_clauses = Clause.includes(:guide).where('subsection_id =? AND guide_id >?', @selected_guide_subsection.id, 0).order('clausetype_id, clause, subclause')
      
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @guide, :layout => 'settings'}
    end
    end
  end  

 def new
   @guide = Guide.new
 end 
 
 def create
   @guide = Guide.new(params[:guide])
   @guide.save
 end 
 


end
