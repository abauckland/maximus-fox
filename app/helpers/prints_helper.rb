module PrintsHelper

  def print_revision_select_list(current_project, project_revisions, selected_revision)    
    if current_project.project_status == 'Draft'
      "<div class='project_label_select'>Project status is 'Draft'</div>".html_safe    
    else
      "<div class='project_label_select'>Revision:</div><div class='project_option_select'>#{print_revision_select_input(project_revisions, selected_revision, current_project)}</div>".html_safe  
    end
  end

    
  def print_revision_select_input(project_revisions, selected_revision, current_project)
    select_tag "revision", options_from_collection_for_select(project_revisions, :id, :rev, selected_revision.id), {:class => 'publish_selectBox', :onchange => "window.location='/prints/#{current_project.id}?revision='+this.value;"}
  end
  
  
  def watermark_checkbox(print_status_show)    

    case print_status_show            
      when 'draft' ;  "A 'not for issue' watermark is placed on the documents when the specification is in Draft status.".html_safe
      when 'superseded' ; "The selected revision of the document has already been published. A watermark 'Superseded' will be added to each page".html_safe    
      when 'issue' ; "This document has already been published, no subsequent changes have been made to it. To create another copy click the 'Print Document' button".html_safe
      when 'not for issue' ; "Confirm this revision of the document will not be issued. A watermark 'Not for Issue' will be added to each page#{check_box_tag 'issue', true, checked = true}".html_safe    
    end

  end

  
  def print_help(print_status_show)
  
     case print_status_show            
      when 'draft' ;  render :partial => "print_help_draft"
      when 'superseded' ;  render :partial => "print_help_superseded"  
      when 'issue' ; 
      when 'not for issue' ; render :partial => "print_help"
    end
 
  end
 
 
##prawn helpers
#cover design 1
def cover(company, current_project, print_revision_rev, pdf)
  
#font styles for page  
  font_style_project_client = {:size => 16, :style => :bold, :align => :right}
  font_style_project_title = {:size => 18, :style => :bold, :align => :right}
  font_style_project_details = {:size => 16, :align => :right}
  font_style_company_info = {:size => 8, :align => :left}  
    
#page content and layout 
  pdf.move_down(10.mm);

  if !company.photo_file_name.blank?
    pdf.image "#{Rails.root}/public#{company.photo.url.sub!(/\?.+\Z/, '') }", :position => :right, :vposition => -0.mm, :fit => [250,35]
  else
    pdf.text "#{current_project.client}", font_style_project_client
  end

  pdf.text "#{@current_project.code} #{@current_project.title}", font_style_project_title
  pdf.text "Architectural Specification", font_style_project_details
  pdf.text "Issue: #{current_project.project_status}", font_style_project_details
  pdf.text "Revision: #{print_revision_rev}", font_style_project_details

  pdf.move_down(10.mm)

  if !current_project.photo_file_name.blank?
    pdf.image "#{Rails.root}/public#{current_project.photo.url.sub!(/\?.+\Z/, '') }", :position => :right, :vposition => :logo_bottom, :fit => [350,250]
  end

  pdf.bounding_box([0,35 + 9.mm], :width => 176.mm, :height => 400) do
    if !company.reg_name.blank?
      pdf.text company.reg_name, font_style_company_info
    end
    if !company.reg_location.blank?
      pdf.text "Registered in #{company.reg_location} No: #{company.reg_number}", font_style_company_info
    end
    if !company.reg_address.blank?
      pdf.text company.reg_address, font_style_company_info
    end
    if !company.tel.blank?
      pdf.text "#{company.www} Tel: #{company.tel}", font_style_company_info
    end
  end
end

def header(company, current_project, pdf)
  
  pdf.line_width(0.1)

  pdf.repeat :omit_first_page do
    if !company.photo_file_name.blank?
      pdf.image "#{Rails.root}/public#{company.photo.url.sub!(/\?.+\Z/, '') }", :position => :right, :vposition => -11.mm, :align => :right, :fit => [250,25]
    end
    pdf.text_box "#{current_project.title}", :size => 9, :at => [0,pdf.bounds.top + 5.mm]
    pdf.stroke do
      pdf.line [0.mm,273.mm],[176.mm,273.mm]
    end
  end
end


def footer(current_project, selected_revision, print_revision_rev, pdf)
  
  pdf.line_width(0.1)

  date = selected_revision.created_at
  reformated_date = date.strftime("#{date.day.ordinalize} %b %Y")

  pdf.repeat :omit_first_page do
    pdf.stroke do
      pdf.line [0.mm,9.mm],[176.mm,9.mm]
    end
    pdf.text_box "#{current_project.code}  Revision: #{print_revision_rev}.", :size => 8, :at => [0,pdf.bounds.bottom + 7.mm]
    pdf.text_box "Created: #{reformated_date}", :size => 8, :at => [0,pdf.bounds.bottom + 3.mm]    
  end  
end


def contents_page(revision_subsections, project_status_changed, current_prelim_subsections, current_none_prelim_subsections, pdf)

#font styles for page  
  font_style_section_title = {:size => 16, :style => :bold}
  font_style_contents = {:size => 12, :leading => 2.mm}
  
#page content and layout
  pdf.move_down(11)
  pdf.text "Document Contents", font_style_section_title
  pdf.move_down(23)

  #list document contents
  if revision_subsections;
    pdf.text "Document Revisions", font_style_contents
  else
    if project_status_changed;
      pdf.text "Document Revisions", font_style_contents
    end  
  end

  if current_prelim_subsections
    pdf.text "A-- Preliminaries", font_style_contents
  end

  current_none_prelim_subsections.each do |subsection|;
    pdf.text subsection.subsection_full_code_and_title, font_style_contents
    #if list of contents does not fit on page start new page
    if pdf.y <= 30.mm
      pdf.text "List of Contents continued on next page...", :size => 10, :style => :italic
      pdf.start_new_page
      pdf.move_down(11)
      pdf.text "Document Contents (continued)", :size => 14, :style => :bold_italic
      pdf.move_down(23)
    end
  end
end



def project_preliminaries(current_project, current_prelim_subsections, pdf)
#font styles for page  
  font_style_section_title = {:size => 16, :style => :bold}
  font_style_clausetype_code = {:size => 11, :style => :bold}
#formating for lines  
  section_title_format = font_style_section_title
  clausetype_code_format = font_style_clausetype_code
  clausetype_title_format = font_style_clausetype_code.merge(:width => 155.mm, :overflow => :expand)   
    
#local variable to store page numbers
  @start_prelim_bookmark = []
  @end_prelim_bookmark = []

    
    pdf.start_new_page;

    @start_prelim_bookmark = pdf.page_number

    #print subsection code and title   
    pdf.spec_box "A-- Preliminaries", section_title_format.merge(:at => [0.mm, 268.mm])
    pdf.move_down(pdf.box_height + 2.mm)

    prefixed_linetypes_array = Linetype.where(:txt1 => true).collect{|i| i.id}
    
    
    current_prelim_subsections.each do |subsection|

      clausetype_speclines = Specline.includes(:clause => [:clauseref]).where(:project_id => current_project, 'clauserefs.subsection_id' => subsection.id).order('clauserefs.clause, clauserefs.subclause, clause_line');
      clausetype_speclines.each_with_index do |line, i| 
        #save y position to refernce after dry run
        y_position = pdf.y
      
        #check fit of line, and related subsequent lines
        print_line_space_check(line, i, clausetype_speclines, prefixed_linetypes_array, pdf)
        
        #if not enough on page start new page
        if pdf.y >= 13.mm
          pdf.y = y_position      
        else
          page_break(line, pdf)
        end
        
        #if first clause of prelim section, insert prelim section title             
        if i == 0
          prelim_subsection_print(subsection, pdf)
        end
        
        #print line
        line_print(line, pdf)
        pdf.move_down(pdf.box_height + 2.mm)        
    end
  @end_prelim_bookmark = pdf.page_number
  end  
end


def project_subsections(current_project, current_none_prelim_subsections, pdf)
#font styles for page  
  font_style_section_title = {:size => 16, :style => :bold}
  font_style_clausetype_code = {:size => 11, :style => :bold}
#formating for lines  
  section_title_format = font_style_section_title
  clausetype_code_format = font_style_clausetype_code
  clausetype_title_format = font_style_clausetype_code.merge(:width => 155.mm, :overflow => :expand)

  
  #local variable to store page numbers
  @sub_start_bookmark = []
  @sub_end_bookmark = []
  
  prefixed_linetypes_array = Linetype.where(:txt1 => true).collect{|i| i.id}


  current_none_prelim_subsections.each_with_index do |subsection, n|

    #start page for each section
    pdf.start_new_page
    pdf.y = 268.mm

    @sub_start_bookmark[n+1] = pdf.page_number
    
    #print subsection code and title   
    pdf.spec_box "#{subsection.section.ref}#{subsection.ref} #{subsection.text}", section_title_format.merge(:at => [0.mm, 268.mm])
    pdf.move_down(pdf.box_height)
    
    #get all clausetypes for the project    
    clausetypes = Clausetype.includes(:clauserefs => [:clauses => :speclines]).where('speclines.project_id' => current_project, 'clauserefs.subsection_id' => subsection.id).order('clausetypes.id')    
    clausetypes.each do |clausetype|

      #get all speclines for each clausetype    
      clausetype_speclines = Specline.includes(:clause => [:clauseref]).where(:project_id => current_project, 'clauserefs.subsection_id' => subsection.id, 'clauserefs.clausetype_id' => clausetype.id).order('clauserefs.clause, clauserefs.subclause, clause_line');

      clausetype_speclines.each_with_index do |line, i|


        #save y position to refernce after dry run
        y_position = pdf.y
      
        #check fit of line, and related subsequent lines
        print_line_space_check(line, i, clausetype_speclines, prefixed_linetypes_array, pdf)

        #if not enough on page start new page
        if pdf.y >= 13.mm
          pdf.y = y_position      
        else
          page_break(line, pdf)
        end
        
        #if first clause of clausetype, insert clause type title
        if i == 0
          clausetype_print(subsection, clausetype, pdf)
        end 
        
        #print line
        line_print(line, pdf)
        pdf.move_down(pdf.box_height + 2.mm)           
      end
    end
    @sub_end_bookmark[n+1] = pdf.page_number    
  end        
end
 

def print_line_space_check(line, i, clausetype_speclines, prefixed_linetypes_array, pdf)
        #if line is clause title
        if i == 0
          pdf.move_down(16.mm)
        end

        #check line
        line_draft(line, pdf)
        pdf.move_down(pdf.draft_box_height + 2.mm)
        
        #establish if clause title will fit on the page when:
        #- at least one line of the clause will fit below it
        #- if the second line in the clause is prefixed, it will also fit on page
        #if none of the above can be achieved then start new page
                
        #if line is a clause title        
        if line.clause_line == 0; 
          #if there is 1st line in clause
          if !clausetype_speclines[i+1].blank?
            #if 1st line is part of same clause
            if clausetype_speclines[i+1].clause_line == 1
              #check line fits  
              line_draft(clausetype_speclines[i+1], pdf)
              pdf.move_down(pdf.draft_box_height + 2.mm)
              #if 1st line does not have a prefix
              if !prefixed_linetypes_array.include?(clausetype_speclines[i+1].linetype_id)
                #if 2nd line exists
                if !clausetype_speclines[i+2].blank?
                  #if 2nd line is part of same clause
                  if clausetype_speclines[i+2].clause_line == 2
                    #if 2nd line is prefixed - check 2nd line also fits                           
                    if prefixed_linetypes_array.include?(clausetype_speclines[i+2].linetype_id)
                      #check line fits  
                      line_draft(clausetype_speclines[i+2], pdf)
                      pdf.move_down(pdf.draft_box_height + 2.mm)
                    end      
                  end
                end
              end          
            end
            #if 1st line is also a clause title
            if clausetype_speclines[i+1].clause_line == 0
              #if 2nd line exists 
              if !clausetype_speclines[i+2].blank?
                #if 2nd line is part of same clause
                if clausetype_speclines[i+2].clause_line == 1
                  #check line fits         
                  line_draft(clausetype_speclines[i+2], pdf)
                  pdf.move_down(pdf.draft_box_height + 2.mm)          
                  #if 2nd line does not have a prefix
                  if !prefixed_linetypes_array.include?(clausetype_speclines[i+2].linetype_id)
                    #if 3rd line exists
                    if !clausetype_speclines[i+3].blank?
                      #if 3rd line is part of same clause
                      if clausetype_speclines[i+3].clause_line == 2
                        #if 3rd line is prefixed - check 2nd line also fits         
                        if prefixed_linetypes_array.include?(clausetype_speclines[i+3].linetype_id)
                          #check line fits   
                          line_draft(clausetype_speclines[i+3], pdf)
                          pdf.move_down(pdf.draft_box_height + 2.mm)    
                        end
                      end
                    end  
                  end
                end  
              end
            end
          end
        end
end


def page_break(line, pdf)
  if line.clause_line == 0
    pdf.start_new_page
    pdf.y = 268.mm 
  else  
    clausetitle_continued(line, pdf)  
    pdf.start_new_page
    pdf.y = 268.mm
      
    clausetitle_repeat(line, pdf)
    pdf.move_down(pdf.box_height + 2.mm) 
  end   
end


def prelim_subsection_print(subsection, pdf)
#font styles for page  
  font_style_clausetype_code = {:size => 11, :style => :bold}
#formating for lines  
  clausetype_code_format = font_style_clausetype_code
  clausetype_title_format = font_style_clausetype_code.merge(:width => 155.mm, :overflow => :expand)

      pdf.move_down(6.mm)         
      pdf.spec_box subsection.section.ref + sprintf("%02d", subsection.ref).to_s, clausetype_code_format.merge(:at =>[0.mm, pdf.y])
      pdf.spec_box subsection.text.upcase, clausetype_title_format.merge(:at =>[20.mm, pdf.y])
      pdf.move_down(pdf.box_height)
end


def clausetype_print(subsection, clausetype, pdf)
#font styles for page  
  font_style_clausetype_code = {:size => 11, :style => :bold}
#formating for lines  
  clausetype_code_format = font_style_clausetype_code
  clausetype_title_format = font_style_clausetype_code.merge(:width => 155.mm, :overflow => :expand)

      pdf.move_down(6.mm)         
      pdf.spec_box subsection.subsection_code + '.' + clausetype.id.to_s + '000', clausetype_code_format.merge(:at =>[0.mm, pdf.y])
      pdf.spec_box clausetype.text.upcase, clausetype_title_format.merge(:at =>[20.mm, pdf.y])
      pdf.move_down(pdf.box_height)
end


#revision line print
def line_draft(line, pdf)
#font styles for lines
  font_style_clause_title = {:size => 11, :style => :bold}
  font_style_specline = {:size => 10}
#formating for lines  
  clausetitle_format = font_style_clause_title.merge(:width => 155.mm, :overflow => :expand)
  prefixed_specline_format = font_style_specline.merge(:width => 140.mm, :overflow => :expand)
  specline_format = font_style_specline.merge(:width => 149.mm, :overflow => :expand)
    
  
    case line.linetype_id
      when 1, 2 ;   draft_linetype_1_helper(line, clausetitle_format, pdf)        
      when 3 ;      pdf.draft_text_box "#{line.txt4.text}: #{line.txt5.text}", prefixed_specline_format.merge(:at =>[30.mm, pdf.y])       
      when 4 ;      pdf.draft_text_box "#{line.txt4.text}", prefixed_specline_format.merge(:at =>[30.mm, pdf.y]) 
      when 7 ;      pdf.draft_text_box "#{line.txt4.text}", specline_format.merge(:at =>[23.mm, pdf.y])
      when 8 ;      pdf.draft_text_box "#{line.txt4.text}: #{line.txt5.text}", specline_format.merge(:at =>[23.mm, pdf.y]) 
      when 10 ;     draft_linetype_8_helper(line, specline_format, pdf)
      when 11 ;     pdf.draft_text_box "#{line.perform.performkey.text}: #{line.identity.perform.performvalue.full_perform_value}", specline_format.merge(:at =>[23.mm, pdf.y])
      when 12 ;     pdf.draft_text_box "#{line.txt4.text}: #{line.txt5.text}", specline_format.merge(:at =>[23.mm, pdf.y])                    
    end    
end

def draft_linetype_1_helper(line, clausetitle_format, pdf)
     pdf.move_down(4.mm)
     pdf.draft_text_box "#{line.clause.clausetitle.text}", clausetitle_format.merge(:at =>[20.mm, pdf.y]) 
end

def draft_linetype_10_helper(line, specline_format, pdf)
  if line.identity.identkey.text == "Manufacturer"
      pdf.draft_text_box "#{line.identity.identkey.text}: #{line.identity.identvalue.company.company_address}", specline_format.merge(:at =>[23.mm, pdf.y]) 
  else
      pdf.draft_text_box "#{line.identity.identkey.text}: #{line.identity.identvalue.identtxt.text}", specline_format.merge(:at =>[23.mm, pdf.y]) 
  end
end

 

def line_print(line, pdf)
#font styles for lines
  font_style_clause_title = {:size => 11, :style => :bold}
  font_style_specline = {:size => 10}

#formating for lines  
  clausetitle_format = font_style_clause_title.merge(:width => 155.mm,:overflow => :expand)
  specline_prefix_format = font_style_specline.merge(:width => 4.mm)
  prefixed_specline_format = font_style_specline.merge(:width => 140.mm,:overflow => :expand)
  indent_format = font_style_specline.merge(:width => 3.mm) 
  specline_format = font_style_specline.merge(:width => 149.mm,:overflow => :expand)


    case line.linetype_id
      when 1, 2 ;   print_linetype_1_helper(line, clausetitle_format, pdf)        
      when 3 ;      print_linetype_3_helper(line, specline_prefix_format, prefixed_specline_format, pdf)       
      when 4 ;      print_linetype_4_helper(line, specline_prefix_format, prefixed_specline_format, pdf) 
      when 7 ;      print_linetype_7_helper(line, indent_format, specline_format, pdf)
      when 8 ;      print_linetype_8_helper(line, indent_format, specline_format, pdf)
      when 10 ;     print_linetype_10_helper(line, indent_format, specline_format, pdf)
      when 11 ;     print_linetype_11_helper(line, indent_format, specline_format, pdf)
      when 12 ;     print_linetype_12_helper(line, indent_format, specline_format, pdf)                   
    end    
end

def print_linetype_1_helper(line, specline_format, pdf)
     pdf.move_down(4.mm)
     pdf.spec_box "#{full_clause_code(line)}", specline_format.merge(:at =>[0.mm, pdf.y]) 
     pdf.spec_box "#{line.clause.clausetitle.text}", specline_format.merge(:at =>[20.mm, pdf.y]) 
end

def print_linetype_3_helper(line, prefix_format, specline_format, pdf)
    pdf.spec_box "#{line.txt1.text}.", prefix_format.merge(:at => [26.mm, pdf.y])
    pdf.spec_box "#{line.txt4.text}: #{line.txt5.text}", specline_format.merge(:at =>[30.mm, pdf.y]) 
end

def print_linetype_4_helper(line, prefix_format, specline_format, pdf)
    pdf.spec_box "#{line.txt1.text}.", prefix_format.merge(:at => [26.mm, pdf.y])
    pdf.spec_box "#{line.txt4.text}", specline_format.merge(:at =>[30.mm, pdf.y]) 
end

def print_linetype_7_helper(line, indent_format, specline_format, pdf)
    pdf.spec_box '-', indent_format.merge(:at => [20.mm, pdf.y]) 
    pdf.spec_box "#{line.txt4.text}", specline_format.merge(:at =>[23.mm, pdf.y]) 
end

def print_linetype_8_helper(line, indent_format, specline_format, pdf)
    pdf.spec_box '-', indent_format.merge(:at => [20.mm, pdf.y]) 
    pdf.spec_box "#{line.txt4.text}: #{line.txt5.text}", specline_format.merge(:at =>[23.mm, pdf.y]) 
end

def print_linetype_10_helper(line, indent_format, specline_format, pdf)
    pdf.spec_box '-', indent_format.merge(:at => [20.mm, pdf.y]) 
    if line.identity.identkey.text == "Manufacturer"  
      pdf.spec_box "#{line.identity.identkey.text}: #{line.identity.identvalue.company.company_name}", specline_format.merge(:at =>[23.mm, pdf.y])  
    else
      pdf.spec_box "#{line.identity.identkey.text}: #{line.identity.identvalue.identtxt.text}", specline_format.merge(:at =>[23.mm, pdf.y])  
    end
end

def print_linetype_11_helper(line, indent_format, specline_format, pdf)
    pdf.spec_box '-', indent_format.merge(:at => [20.mm, pdf.y]) 
    pdf.spec_box "#{line.perform.performkey.text}: #{line.identity.perform.performvalue.full_perform_value}", specline_format.merge(:at =>[23.mm, pdf.y]) 
end

def print_linetype_12_helper(line, indent_format, specline_format, pdf)
    pdf.spec_box '-', indent_format.merge(:at => [20.mm, pdf.y]) 
    pdf.spec_box "#{line.txt4.text}: #{line.txt5.text}", specline_format.merge(:at =>[23.mm, pdf.y]) 
end



def clausetitle_continued(line, pdf)
     pdf.spec_box 'Clause continued on next page...', :size => 9, :style => :italic, :at =>[20.mm, 14.mm], :width => 155.mm, :overflow => :expand
end

def clausetitle_repeat(line, pdf)
     pdf.spec_box full_clause_code(line), :size => 10, :style => :bold_italic, :at =>[0.mm, pdf.y], :width => 20.mm, :height => 5.mm
     pdf.spec_box line.clause.clausetitle.text + ' (continued)', :size => 10, :style => :bold_italic, :at =>[20.mm, pdf.y], :width => 155.mm, :overflow => :expand
end
















def revisions(current_project, selected_revision, project_status_changed, previous_revision_project_status, current_revision_project_status, array_of_new_subsections_compacted, array_of_deleted_subsections_compacted, array_of_changed_subsections_compacted, hash_of_deleted_clauses, hash_of_new_clauses, hash_of_changed_clauses)


#font styles for page  
  font_style_section_title =          {:size => 16, :style => :bold}
  font_style_clausetype_code_title =  {:size => 11, :style => :bold}
  font_style_rev_section_action =     {:size => 12, :style => :bold_italic}
  
  font_style_rev_section_title =      {:size => 11}
  font_style_rev_clause_action =      {:size => 11, :style => :bold}
  font_style_rev_clause_code_title =  {:size => 11, :style => :bold}
  font_style_rev_line_action =        {:size => 9, :style => :bold_italic}
  font_style_rev_line_sub_action =    {:size => 8, :style => :italic}
 
#formating for lines  
  section_title_format = font_style_section_title.merge(section_title_dims)
  clausetype_code_format = font_style_clausetype_code_title.merge(clausetype_code_dims)
  clausetype_title_format = font_style_clausetype_code_title.merge(:width => 155.mm, :overflow => :expand)
  
  rev_section_action_format = font_style_rev_section_action.merge(:width => 50.mm)
  rev_section_title_format = font_style_rev_section_title.merge(:width => 158.mm, :overflow => :expand)
  rev_clause_action_format = font_style_rev_clause_action.merge(:width => 100.mm)
  rev_clause_title_format = font_style_rev_clause_code_title.merge(:width => 135.mm, :overflow => :expand)
  rev_clause_code_format = font_style_rev_clause_code_title.merge(:width => 20.mm)
  rev_line_action_format = font_style_rev_line_action.merge(:width => 50.mm)
  rev_line_sub_action_format = font_style_rev_line_sub_action.merge(:width => 20.mm)   


    pdf.start_new_page
    pdf.y = 268.mm

    @rev_start_bookmark = []
    @rev_start_bookmark[0] = pdf.page_number


    pdf.spec_box "Document Revisions", section_title_format.merge(:at => [0.mm, pdf.y])
    pdf.move_down(pdf.box_height + 2.mm)


if project_status_changed
  pdf.spec_box "Document Status Changed from #{previous_revision_project_status} to #{current_revision_project_status}:", :size => 11, :at => [0.mm, pdf.y], :width => 165.mm, :height => 7.mm;
  pdf.move_down(pdf.box_height + 2.mm)
end



  
if !array_of_new_subsections_compacted.blank?;  
  #save y position to refernce after dry run
  y_position = pdf.y
  
  #check will fit on page   
  pdf.draft_text_box "Subsections added:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.draft_box_height + 2.mm)   
  
  check_rev_prelim_title_fit(array_of_new_subsections_compacted, rev_section_title_format, pdf)  
  array_of_new_subsections_compacted.each do |subsection|  
    check_rev_section_changes_fit(subsection, rev_section_title_format, pdf)
  end      
  
  #start new page if does not fit or reset y value         
  check_new_page(y_position, pdf)     
  
  #print list of subsections added
  pdf.spec_box "Subsections added:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.box_height + 2.mm) 
  
  print_rev_prelim_title(array_of_new_subsections_compacted, rev_section_title_format, pdf)  
  array_of_new_subsections_compacted.each do |subsection|  
    print_rev_section_changes(subsection, rev_section_title_format, pdf)
  end    
end


if !array_of_deleted_subsections_compacted.blank? 
  #save y position to refernce after dry run
  y_position = pdf.y
  
  #check will fit on page 
  pdf.draft_text_box "Subsections deleted:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.draft_box_height + 2.mm) 
  
  check_rev_prelim_title_fit(array_of_deleted_subsections_compacted, rev_section_title_format, pdf)  
  array_of_deleted_subsections_compacted.each do |subsection|  
    check_rev_section_changes_fit(subsection, rev_section_title_format, pdf)
  end      
  
  #start new page if does not fit or reset y value         
  check_new_page(y_position, pdf)     
  
  #print list of subsections added
  pdf.spec_box "Subsections deleted:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.box_height + 2.mm)
  
  print_rev_prelim_title(array_of_deleted_subsections_compacted, rev_section_title_format, pdf)
  array_of_deleted_subsections_compacted.each do |subsection|  
    print_rev_section_changes(subsection, rev_section_title_format, pdf)
  end   
end


if !array_of_changed_subsections_compacted.blank?
  #save y position to refernce after dry run
  y_position = pdf.y
  
  #check title will fit on page   
  pdf.draft_text_box "Subsections changed:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.draft_box_height + 2.mm)   
  
  check_rev_section_changes_fit(subsection, rev_section_title_format, pdf)
  
  #start new page if does not fit or reset y value
  if pdf.y <= 16.mm
    pdf.start_new_page
    pdf.y = 268.mm
  else
    pdf.y = y_position   
  end  
  
  
  pdf.spec_box "Subsections changed:", rev_section_action_format.merge(:at => [0.mm, pdf.y])
  pdf.move_down(pdf.box_height + 2.mm)

  print_rev_prelim_title(array_of_changed_subsections_compacted, rev_section_title_format, pdf)


###next line in wrong place
  array_of_changed_subsections_compacted.each do |changed_subsection|
 
    print_rev_section_changes(changed_subsection, rev_section_title_format, pdf)

    if !hash_of_deleted_clauses[changed_subsection.id].blank?
      
      hash_of_deleted_clauses_compacted = hash_of_deleted_clauses[changed_subsection.id].compact
      #save y position to refernce after dry run
      y_position = pdf.y      

      #check will fit on page 
      pdf.draft_text_box "Subsection clauses deleted:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.daft_box_height + 2.mm)      
      hash_of_deleted_clauses_compacted.each do |clause|         
        draft_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)
      end         

      #start new page if does not fit or reset y value         
      check_new_page(y_position, pdf)
       
      #print list of text deleted from clasue            
      pdf.spec_box "Subsection clauses deleted:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm)
      hash_of_deleted_clauses_compacted.each do |clause|                
        print_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)            
      end
    end
 

    if !hash_of_new_clauses[changed_subsection.id].blank?
      
      hash_of_new_clauses_compacted = hash_of_new_clauses[changed_subsection.id].compact
      #save y position to refernce after dry run
      y_position = pdf.y

      #check will fit on page 
      pdf.draft_text_box "Subsection clauses added:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.daft_box_height + 2.mm)      
      hash_of_new_clauses_compacted.each do |clause|         
        draft_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)
      end         

      #start new page if does not fit or reset y value         
      check_new_page(y_position, pdf) 

      #print list of text deleted from clasue  
      pdf.spec_box "Subsection clauses added:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm)
      hash_of_new_clauses_compacted.each do |clause|         
        print_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)
      end     
    end



    if !hash_of_changed_clauses[changed_subsection.id].blank?
      pdf.spec_box "Subsection clauses changed:", rev_clause_action_format.merge(:at => [10.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm)
      hash_of_changed_clauses_compacted = hash_of_changed_clauses[changed_subsection.id].compact

####STILL TO CHECK      
      hash_of_changed_clauses_compacted.each do |clause|
        print_rev_clause_code_title(clause, rev_clause_code_format, rev_clause_title_format, pdf)

            
        deleted_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', current_project.id, clause, selected_revision.id, 'deleted')
        if deleted_lines
          #save y position to refernce after dry run
          y_position = pdf.y
          
          #check will fit on page
          pdf.draft_text_box "Text deleted:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
          pdf.move_down(pdf.draft_box_height + 1.mm)
          
          deleted_lines.each do |deleted_line|      
              rev_line_draft(line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)                            
          end
          
          #start new page if does not fit or reset y value         
          check_new_page(y_position, pdf)           
          
          #print list of text deleted from clasue
          pdf.spec_box "Text deleted:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
          pdf.move_down(pdf.box_height + 1.mm)          
          
          deleted_lines.each do |deleted_line|
              rev_line_print(line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)      
          end
        end

        added_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', current_project.id, clause, selected_revision.id, 'new')
        if added_lines
          #save y position to refernce after dry run
          y_position = pdf.y
          
          #check will fit on page
          pdf.draft_text_box "Text added:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
          pdf.move_down(pdf.draft_box_height + 1.mm)
          
          added_lines.each do |added_line|      
              rev_line_draft(line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)                            
          end
          
          #start new page if does not fit or reset y value         
          check_new_page(y_position, pdf) 
                      
          #print list of text added to clasue
          pdf.spec_box "Text added:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
          pdf.move_down(pdf.box_height + 1.mm)
          
          added_lines.each do |added_line|      
              rev_line_print(line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)                            
          end
        end


       changed_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', current_project.id, clause, selected_revision.id, 'changed')
        if changed_lines
          check_changed_print_status = changed_lines.collect{|item| item.print_change}.uniq
          if check_changed_print_status.include?(true)
            
            #save y position to refernce after dry run
            y_position = pdf.y            

            #check will fit on page
            pdf.draft_text_box "Text changed:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
            pdf.move_down(pdf.draft_box_height + 1.mm)
          
            changed_lines.each do |changed_line|
#check this is correct
              subsequent_change = Change.where('id > ? AND specline_id = ?', changed_line.id, changed_line.specline_id).first 
              if subsequent_change
                previous_line = subsequent_change                
              else
                current_line = Specline.find(changed_line.specline_id)    
              end
                    
              pdf.draft_text_box "From:", rev_line_sub_action_format.merge(:at =>[35.mm, pdf.y])
              pdf.move_down(pdf.box_height)
              
              rev_line_draft(previous_line, pdf)
              pdf.move_down(pdf.draft_box_height)
                            
              pdf.draft_text_box "To:", rev_line_sub_action_format.merge(:at =>[35.mm, pdf.y])
              pdf.move_down(pdf.box_height)
              
              rev_line_draft(current_line, pdf)
              pdf.move_down(pdf.draft_box_height + 2.mm)
                                                        
            end
            
            #start new page if does not fit or reset y value         
            check_new_page(y_position, pdf)                         
   
            #print list of text changed in clasue
            pdf.spec_box "Text changed:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
            pdf.move_down(pdf.box_height + 1.mm)
         
            changed_lines.each do |changed_line|;
#check this is correct
              subsequent_change = Change.where('id > ? AND specline_id = ?', changed_line.id, changed_line.specline_id).first 
              if subsequent_change
                previous_line = subsequent_change                
              else
                current_line = Specline.find(changed_line.specline_id)    
              end
              
              pdf.spec_box "From:", rev_line_sub_action_format.merge(:at =>[35.mm, pdf.y])
              pdf.move_down(pdf.box_height)
                
              rev_line_print(previous_line, pdf)
              pdf.move_down(pdf.box_height)

              pdf.spec_box "To:", rev_line_sub_action_format.merge(:at =>[35.mm, pdf.y])
              pdf.move_down(pdf.box_height)
                                 
              rev_line_print(current_line, pdf)
              pdf.move_down(pdf.box_height + 2.mm)                     
            end        

          else
            #save y position to refernce after dry run
            y_position = pdf.y            

            #check will fit on page            
            pdf.draft_text_box "Text changed:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
            pdf.move_down(pdf.draft_box_height)            
            
            pdf.draft_text_box "Some minor spelling and grammatical changes have been made to this clause. For this reason revision details have not been recorded.", :size => 10, :style => :italic, :at =>[35.mm,rev_row_y_b], :width => 140.mm, :height => 5.mm, :overflow => :expand;
            pdf.move_down(pdf.draft_box_height + 2.mm)            
            
            #start new page if does not fit or reset y value         
            check_new_page(y_position, pdf)                       
   
            #print list of text changed in clasue           
            pdf.spec_box "Text changed:", rev_line_action_format.merge(:at => [35.mm, pdf.y])
            pdf.move_down(pdf.box_height)            
            
            pdf.spec_box "Some minor spelling and grammatical changes have been made to this clause. For this reason revision details have not been recorded.", :size => 10, :style => :italic, :at =>[35.mm,rev_row_y_b], :width => 140.mm, :height => 5.mm, :overflow => :expand;
            pdf.move_down(pdf.box_height + 2.mm) 
          end
        end
      end
    end
  end
end



@rev_end_bookmark = [];
@rev_end_bookmark[0] = pdf.page_number;

end


def check_new_page(y_position, pdf)  
  if pdf.y <= 16.mm
    pdf.start_new_page
    pdf.y = 268.mm
  else
    pdf.y = y_position   
  end   
end



def print_rev_prelim_title(subsections, format, pdf)  
    if subsections.first.section_id == 1   
      pdf.spec_box "A-- Preliminaries:", format.merge(:at => [5.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm) 
    end
end


def check_rev_prelim_title_fit(subsections, format, pdf)  
  if subsections.first.section_id == 1   
    pdf.draft_text_box "A-- Preliminaries:", format.merge(:at => [5.mm, pdf.y])
    pdf.move_down(pdf.draft_box_height + 2.mm) 
  end
end

def print_rev_prelim_title(subsections, format, pdf)  
    if subsections.first.section_id == 1   
      pdf.spec_box "A-- Preliminaries:", format.merge(:at => [5.mm, pdf.y])
      pdf.move_down(pdf.box_height + 2.mm) 
    end
end

def check_rev_section_changes_fit(subsection, format, pdf)    
    if subsection.section_id == 1
      x = 7.mm
    else
      x = 5.mm 
    end
    pdf.draft_text_box "#{subsection.subsection_full_code_and_title}", format.merge(:at => [x, pdf.y])
    pdf.move_down(pdf.draft_box_height + 2.mm)   
end

def print_rev_section_changes(subsection, format, pdf)      
    if subsection.section_id == 1
      x = 7.mm
    else
      x = 5.mm 
    end
    pdf.spec_box "#{subsection.subsection_full_code_and_title}", format.merge(:at => [x, pdf.y])
    pdf.move_down(pdf.box_height + 2.mm)     
end

def draft_rev_clause_code_title (clause, format_code, format_title, pdf)
    pdf.spec_box "#{clause.clause_code}", format_code.merge(:at => [15.mm, pdf.y])
    pdf.spec_box "#{clause.clausetitle.text}", format_title.merge( :at => [35.mm, pdf.y])
    pdf.move_down(pdf.box_height + 2.mm)
end

def print_rev_clause_code_title (clause, format_code, format_title, pdf)
    pdf.spec_box "#{clause.clause_code}", format_code.merge(:at => [15.mm, pdf.y])
    pdf.spec_box "#{clause.clausetitle.text}", format_title.merge( :at => [35.mm, pdf.y])
    pdf.move_down(pdf.box_height + 2.mm)
end

def rev_line_draft(line, pdf)
#font styles for lines
  font_style_rev_line = {:size => 10}
#formating for lines  
  rev_line_format = font_style_rev_line.merge(:width => 134.mm, :overflow => :expand)

    case line.linetype_id       
      when 3 ; pdf.draft_text_box "#{line.txt4.text}", rev_line_format.merge(:at =>[40.mm, pdf.y])       
      when 4 ; pdf.draft_text_box "#{ine.txt4.text}: #{line.txt5.text}", rev_line_format.merge(:at =>[40.mm, pdf.y])  
      when 7 ; pdf.draft_text_box "#{line.txt4.text}", rev_line_format.merge(:at =>[40.mm, pdf.y]) 
      when 8 ; pdf.draft_text_box "#{line.txt4.text}: #{line.txt5.text}", rev_line_format.merge(:at =>[40.mm, pdf.y])
      when 10 ; rev_draft_linetype_10_helper(line, rev_line_format, pdf) 
      when 11 ; pdf.draft_text_box "#{line.perform.performkey.text}: #{line.identity.perform.performvalue.full_perform_value}", rev_line_format.merge(:at =>[40.mm, pdf.y])  
      when 12 ; pdf.draft_text_box "#{line.txt4.text}: #{line.txt5.text}", rev_line_format.merge(:at =>[40.mm, pdf.y])           
    end    
end


def rev_draft_linetype_10_helper(line, rev_line_format, pdf) 
  if line.identity.identkey.text == "Manufacturer"
     pdf.draft_text_box "#{line.identity.identkey.text}: #{line.identity.identvalue.company.company_name}", rev_line_format.merge(:at =>[40.mm, pdf.y]) 
  else
     pdf.draft_text_box "#{line.identity.identkey.text}: #{line.identity.identvalue.identtxt.text}", rev_line_format.merge(:at =>[40.mm, pdf.y]) 
  end
end



def rev_line_print(line, row_y_b, pdf)
  font_style_specline = {:size => 10}
  
  indent_format = font_style_specline.merge(:width => 3.mm) 
  specline_format = font_style_specline.merge(:width => 134.mm, :overflow => :expand)
  
  case line.linetype_id
    when 1, 2 then print_linetype_1_helper(line, row_y_b, pdf) 
    when 3 then rev_print_linetype_3_helper(line, indent_format, specline_format, pdf)        
    when 4 then rev_print_linetype_4_helper(line, indent_format, specline_format, pdf) 
    when 7 then rev_print_linetype_7_helper(line, indent_format, specline_format, pdf) 
    when 8 then rev_print_linetype_8_helper(line, indent_format, specline_format, pdf)
    when 10 then rev_print_linetype_8_helper(line, indent_format, specline_format, pdf)
    when 11 then rev_print_linetype_8_helper(line, indent_format, specline_format, pdf)
    when 12 then rev_print_linetype_8_helper(line, indent_format, specline_format, pdf)                   
  end    
end


def rev_print_linetype_3_helper(line, indent_format, specline_format, pdf)
  pdf.spec_box '-', indent_format.merge(:at => [37.mm, pdf.y])
  pdf.spec_box "#{line.txt4.text}: #{line.txt5.text}", specline_format.merge(:at =>[40.mm, pdf.y])
end

def rev_print_linetype_4_helper(line, indent_format, specline_format, pdf)
  pdf.spec_box '-', indent_format.merge(:at => [37.mm, pdf.y])
    pdf.spec_box "#{line.txt4.text}", specline_format.merge(:at =>[40.mm, pdf.y])
end

def rev_print_linetype_7_helper(line, indent_format, specline_format, pdf)
  pdf.spec_box '-', indent_format.merge(:at => [37.mm, pdf.y])
  pdf.spec_box "#{line.txt4.text}", specline_format.merge(:at =>[40.mm, pdf.y])
end

def rev_print_linetype_8_helper(line, indent_format, specline_format, pdf)
  pdf.spec_box '-', indent_format.merge(:at => [37.mm, pdf.y])
  pdf.spec_box "#{line.txt4.text}: #{line.txt5.text}", specline_format.merge(:at =>[40.mm, pdf.y])
end

def rev_print_linetype_10_helper(line, indent_format, specline_format, pdf)
  pdf.spec_box '-', indent_format.merge(:at => [37.mm, pdf.y])
  if line.identity.identkey.text == "Manufacturer"
    pdf.spec_box "#{line.identity.identkey.text}: #{line.identity.identvalue.company.company_name}", specline_format.merge(:at =>[40.mm, pdf.y])
  else
    pdf.spec_box "#{line.identity.identkey.text}: #{line.identity.identvalue.identtxt.text}", specline_format.merge(:at =>[40.mm, pdf.y])
  end
end

def rev_print_linetype_11_helper(line, indent_format, specline_format, pdf)
  pdf.spec_box '-', indent_format.merge(:at => [37.mm, pdf.y])
  pdf.spec_box "#{line.perform.performkey.text}: #{line.identity.perform.performvalue.full_perform_value}", specline_format.merge(:at =>[40.mm, pdf.y])
end

def rev_print_linetype_12_helper(line, indent_format, specline_format, pdf)
  pdf.spec_box '-', indent_format.merge(:at => [37.mm, pdf.y])
  pdf.spec_box "#{line.txt4.text}: #{line.txt5.text}", specline_format.merge(:at =>[40.mm, pdf.y])
end







def watermark_helper(watermark, superseded, pdf)
  if watermark[0].to_i == 1
      pdf.transparent(0.15) do
        pdf.text_box "not for issue", :width => 250.mm, :size => 108, :style => :bold, :at => [20.mm,55.mm], :rotate => 60
      end
  end
  if superseded[0].to_i == 1
      pdf.transparent(0.15) do
        pdf.text_box "superseded", :width => 250.mm, :size => 108, :style => :bold, :at => [20.mm,55.mm], :rotate => 60
      end
  end  
end



##further sub helpers for prawn
def full_clause_code(line)
  line.clause.clauseref.subsection.section.ref + sprintf("%02d", line.clause.clauseref.subsection.ref).to_s + '.' + line.clause.clauseref.clausetype_id.to_s + sprintf("%02d", line.clause.clauseref.clause).to_s + line.clause.clauseref.subclause.to_s
end







   
end