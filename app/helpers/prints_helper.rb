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
#revision line print
def rev_print_linetype_5_helper(line, row_y_b, pdf)
       box_width = pdf.width_of line.txt3.text + ':', :size => 10
       nbox_x = box_width + 35.mm
       nbox_width = 175.mm - nbox_x
       pdf.text_box line.txt3.text + ':', :size => 10, :at => [35.mm,rev_row_y_b], :width => box_width, :height => 5.mm
       pdf.spec_box line.txt6.text + '.', :size => 10, :at =>[nbox_x,rev_row_y_b], :width => nbox_width, :height => 5.mm, :overflow => :expand
end

def rev_print_linetype_6_helper(line, row_y_b, pdf)
       box_width = pdf.width_of line.txt3.text + ':', :size => 10
       nbox_x = box_width + 35.mm
       nbox_width = 175.mm - nbox_x
       pdf.text_box line.txt3.text + ':', :size => 10, :at => [35.mm,rev_row_y_b], :width => box_width, :height => 5.mm
       pdf.spec_box line.txt5.text + '.', :size => 10, :at =>[nbox_x,rev_row_y_b], :width => nbox_width, :height => 5.mm, :overflow => :expand
end

def rev_line_draft(line, row_y_a, pdf)
    case line.linetype_id
      when 1, 2 ; draft_linetype_1_helper(line, row_y_a, pdf)        

      when 3 ; rev_draft_linetype_3_helper(line, row_y_a, pdf)        
      when 4 ; rev_draft_linetype_4_helper(line, row_y_a, pdf) 
      when 5 ; rev_draft_linetype_5_helper(line, row_y_a, pdf) 
      when 6 ; rev_draft_linetype_6_helper(line, row_y_a, pdf) 
      when 7 ; rev_draft_linetype_7_helper(line, row_y_a, pdf) 
      when 8 ; rev_draft_linetype_8_helper(line, row_y_a, pdf)           
    end    
end


def line_draft(line, row_y_a, pdf)
    case line.linetype_id
      when 1, 2 ; draft_linetype_1_helper(line, row_y_a, pdf)        

      when 3 ; draft_linetype_3_helper(line, row_y_a, pdf)        
      when 4 ; draft_linetype_4_helper(line, row_y_a, pdf) 
      when 5 ; draft_linetype_5_helper(line, row_y_a, pdf) 
      when 6 ; draft_linetype_6_helper(line, row_y_a, pdf) 
      when 7 ; draft_linetype_7_helper(line, row_y_a, pdf) 
      when 8 ; draft_linetype_8_helper(line, row_y_a, pdf)           
    end    
end

def draft_linetype_1_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.clause.clauseref.subsection.section.ref + sprintf("%02d", line.clause.clauseref.subsection.ref).to_s + '.' + line.clause.clauseref.clausetype_id.to_s + sprintf("%02d", line.clause.clauseref.clause).to_s + line.clause.clauseref.subclause.to_s, :size => 10, :style => :bold, :at =>[0.mm,row_y_a], :width => 20.mm, :height => 5.mm
    pdf.draft_text_box line.clause.clausetitle.text, :size => 10, :style => :bold, :at =>[20.mm,row_y_a], :width => 155.mm, :height => 5.mm, :overflow => :expand
 
end

def draft_linetype_2_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.clause.clauseref.subsection.section.ref + sprintf("%02d", line.clause.clauseref.subsection.ref).to_s + '.' + line.clause.clauseref.clausetype_id.to_s + sprintf("%02d", line.clause.clauseref.clause).to_s + line.clause.clauseref.subclause.to_s, :size => 10, :style => :bold, :at =>[0.mm,row_y_a], :width => 20.mm, :height => 5.mm
    pdf.draft_text_box line.clause.clausetitle.text, :size => 10, :style => :bold, :at =>[20.mm,row_y_a], :width => 155.mm, :height => 5.mm, :overflow => :expand
 
end

def draft_linetype_3_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.txt4.text + '.', :size => 10, :at =>[35.mm,row_y_a], :width => 140.mm, :height => 5.mm, :overflow => :expand
  
end


def draft_linetype_4_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.txt4.text + ':' + line.txt5.text + '.', :size => 10, :at =>[35.mm,row_y_a], :width => 140.mm, :height => 5.mm, :overflow => :expand   
 
end
 

def draft_linetype_5_helper(line, row_y_a, pdf)
    box_width = pdf.width_of line.txt3.text + ':', :size => 10
    nbox_x = box_width + 22.mm
    nbox_width = 150.mm - box_width
    pdf.draft_text_box line.txt6.text + '.', :size => 10, :at =>[nbox_x,row_y_a], :width => nbox_width, :height => 5.mm, :overflow => :expand      
 
end

def draft_linetype_6_helper(line, row_y_a, pdf)
    box_width = pdf.width_of line.txt3.text + ':', :size => 10
    nbox_x = box_width + 22.mm
    nbox_width = 150.mm - box_width
    pdf.draft_text_box line.txt5.text + '.', :size => 10, :at =>[nbox_x,row_y_a], :width => nbox_width, :height => 5.mm, :overflow => :expand       
 
end

def draft_linetype_7_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.txt4.text + '.', :size => 10, :at =>[23.mm,row_y_a], :width => 149.mm, :height => 5.mm, :overflow => :expand   
 
end

def draft_linetype_8_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.txt4.text + ':' + line.txt5.text + '.', :size => 10, :at =>[23.mm,row_y_a], :width => 149.mm, :height => 5.mm, :overflow => :expand   
 
end

def rev_draft_linetype_3_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.txt4.text + '.', :size => 10, :at =>[40.mm,row_y_a], :width => 134.mm, :height => 5.mm, :overflow => :expand
  
end


def rev_draft_linetype_4_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.txt4.text + ':' + line.txt5.text + '.', :size => 10, :at =>[40.mm,row_y_a], :width => 134.mm, :height => 5.mm, :overflow => :expand   
 
end
 

def rev_draft_linetype_5_helper(line, row_y_a, pdf)
    box_width = pdf.width_of line.txt3.text + ':', :size => 10
    nbox_x = box_width + 22.mm
    nbox_width = 134.mm - box_width
    pdf.draft_text_box line.txt6.text + '.', :size => 10, :at =>[nbox_x,row_y_a], :width => nbox_width, :height => 5.mm, :overflow => :expand      
 
end

def rev_draft_linetype_6_helper(line, row_y_a, pdf)
    box_width = pdf.width_of line.txt3.text + ':', :size => 10
    nbox_x = box_width + 22.mm
    nbox_width = 134.mm - box_width
    pdf.draft_text_box line.txt5.text + '.', :size => 10, :at =>[nbox_x,row_y_a], :width => nbox_width, :height => 5.mm, :overflow => :expand       
 
end

def rev_draft_linetype_7_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.txt4.text + '.', :size => 10, :at =>[40.mm,row_y_a], :width => 134.mm, :height => 5.mm, :overflow => :expand   
 
end

def rev_draft_linetype_8_helper(line, row_y_a, pdf)
    pdf.draft_text_box line.txt4.text + ':' + line.txt5.text + '.', :size => 10, :at =>[40.mm,row_y_a], :width => 134.mm, :height => 5.mm, :overflow => :expand   
 
end




def prelim_subsection_print(subsection, row_y_b, pdf, i)
if i == 0
    pdf.text_box subsection.section.ref + sprintf("%02d", subsection.ref).to_s, :size => 11, :style => :bold, :at => [0.mm,row_y_b], :height => 7.mm
    pdf.text_box subsection.text.upcase, :size => 11, :style => :bold, :at => [20.mm,row_y_b], :height => 7.mm
end
end


def clausetype_print(subsection, clausetype, row_y_b, pdf)

  
  pdf.text_box subsection.section.ref + sprintf("%02d", subsection.ref).to_s + '.' + clausetype.id.to_s + '000', :size => 11, :style => :bold, :at =>[0.mm,row_y_b], :width => 20.mm, :height => 7.mm
  pdf.text_box clausetype.text.upcase, :size => 11, :style => :bold, :at =>[20.mm,row_y_b], :width => 155.mm, :height => 7.mm, :overflow => :expand
end

def rev_line_print(line, row_y_b, pdf)
  
    case line.linetype_id
      when 1, 2 then print_linetype_1_helper(line, row_y_b, pdf) 
      when 3 then rev_print_linetype_3_helper(line, row_y_b, pdf)        
      when 4 then rev_print_linetype_4_helper(line, row_y_b, pdf) 
      when 5 then rev_print_linetype_5_helper(line, row_y_b, pdf) 
      when 6 then rev_print_linetype_6_helper(line, row_y_b, pdf) 
      when 7 then rev_print_linetype_7_helper(line, row_y_b, pdf) 
      when 8 then rev_print_linetype_8_helper(line, row_y_b, pdf)           
    end    
end


def line_print(line, row_y_b, pdf)
  
    case line.linetype_id
      when 1, 2 then print_linetype_1_helper(line, row_y_b, pdf) 
      when 3 then print_linetype_3_helper(line, row_y_b, pdf)        
      when 4 then print_linetype_4_helper(line, row_y_b, pdf) 
      when 5 then print_linetype_5_helper(line, row_y_b, pdf) 
      when 6 then print_linetype_6_helper(line, row_y_b, pdf) 
      when 7 then print_linetype_7_helper(line, row_y_b, pdf) 
      when 8 then print_linetype_8_helper(line, row_y_b, pdf)           
    end    
end

def print_linetype_1_helper(line, row_y_b, pdf)
     pdf.text_box line.clause.clauseref.subsection.section.ref + sprintf("%02d", line.clause.clauseref.subsection.ref).to_s + '.' + line.clause.clauseref.clausetype_id.to_s + sprintf("%02d", line.clause.clauseref.clause).to_s + line.clause.clauseref.subclause.to_s, :size => 10, :style => :bold, :at =>[0.mm,row_y_b], :width => 20.mm, :height => 5.mm
     pdf.spec_box line.clause.clausetitle.text, :size => 10, :style => :bold, :at =>[20.mm,row_y_b], :width => 155.mm, :height => 8.mm, :overflow => :expand

end

def print_linetype_2_helper(line, row_y_b, pdf)
     pdf.text_box line.clause.clauseref.subsection.section.ref + sprintf("%02d", line.clause.clauseref.subsection.ref).to_s + '.' + line.clause.clauseref.clausetype_id.to_s + sprintf("%02d", line.clause.clauseref.clause).to_s + line.clause.clauseref.subclause.to_s, :size => 10, :style => :bold, :at =>[0.mm,row_y_b], :width => 20.mm, :height => 5.mm
     pdf.spec_box line.clause.clausetitle.text, :size => 10, :style => :bold, :at =>[20.mm,row_y_b], :width => 155.mm, :height => 8.mm, :overflow => :expand

end

def print_linetype_3_helper(line, row_y_b, pdf)
    pdf.text_box line.txt1.text + '.', :size => 10, :at => [26.mm,row_y_b], :width => 4.mm, :height => 5.mm  
    pdf.spec_box line.txt4.text + ': ' + line.txt5.text + '.', :size => 10, :at =>[30.mm,row_y_b], :width => 140.mm, :height => 5.mm, :overflow => :expand
end


def print_linetype_4_helper(line, row_y_b, pdf)
    pdf.text_box line.txt1.text + '.', :size => 10, :at => [26.mm,row_y_b], :width => 4.mm, :height => 5.mm
    pdf.spec_box line.txt4.text + '.', :size => 10, :at =>[30.mm,row_y_b], :width => 140.mm, :height => 5.mm, :overflow => :expand
end
 


def print_linetype_5_helper(line, row_y_b, pdf)
    box_width = pdf.width_of line.txt3.text + ':', :size => 10
          nbox_x = box_width + 25.mm
           nbox_width = 150.mm - box_width
    pdf.text_box '-', :size => 10, :at => [20.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.text_box line.txt3.text + ':', :size => 10, :at => [23.mm,row_y_b], :width => box_width, :height => 5.mm
    pdf.spec_box line.txt6.text + '.', :size => 10, :at =>[nbox_x,row_y_b], :width => nbox_width, :height => 5.mm, :overflow => :expand 
end

def print_linetype_6_helper(line, row_y_b, pdf)
    box_width = pdf.width_of line.txt3.text + ':', :size => 10
          nbox_x = box_width + 25.mm
           nbox_width = 150.mm - box_width
    pdf.text_box '-', :size => 10, :at => [20.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.text_box line.txt3.text + ':', :size => 10, :at => [23.mm,row_y_b], :width => box_width + 2.mm, :height => 5.mm
    pdf.spec_box line.txt5.text + '.', :size => 10, :at =>[nbox_x,row_y_b], :width => nbox_width, :height => 5.mm, :overflow => :expand

end

def print_linetype_7_helper(line, row_y_b, pdf)
    pdf.text_box '-', :size => 10, :at => [20.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.spec_box line.txt4.text + '.', :size => 10, :at =>[23.mm,row_y_b], :width => 149.mm, :height => 5.mm, :overflow => :expand
end

def print_linetype_8_helper(line, row_y_b, pdf)
    pdf.text_box '-', :size => 10, :at => [20.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.spec_box line.txt4.text + ': ' + line.txt5.text + '.', :size => 10, :at =>[23.mm,row_y_b], :width => 149.mm, :height => 5.mm, :overflow => :expand
end


def rev_print_linetype_3_helper(line, row_y_b, pdf)
      pdf.text_box '-', :size => 10, :at => [37.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.spec_box line.txt4.text + ': ' + line.txt5.text + '.', :size => 10, :at =>[40.mm,row_y_b], :width => 134.mm, :height => 5.mm, :overflow => :expand
end

def rev_print_linetype_4_helper(line, row_y_b, pdf)
      pdf.text_box '-', :size => 10, :at => [37.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.spec_box line.txt4.text + '.', :size => 10, :at =>[40.mm,row_y_b], :width => 134.mm, :height => 5.mm, :overflow => :expand
end

def rev_print_linetype_5_helper(line, row_y_b, pdf)
    box_width = pdf.width_of line.txt3.text + ':', :size => 10
          nbox_x = box_width + 25.mm
           nbox_width = 135.mm - box_width
    pdf.text_box '-', :size => 10, :at => [37.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.text_box line.txt3.text + ':', :size => 10, :at => [40.mm,row_y_b], :width => box_width, :height => 5.mm
    pdf.spec_box line.txt6.text + '.', :size => 10, :at =>[nbox_x,row_y_b], :width => nbox_width, :height => 5.mm, :overflow => :expand 
end

def rev_print_linetype_6_helper(line, row_y_b, pdf)
    box_width = pdf.width_of line.txt3.text + ':', :size => 10
          nbox_x = box_width + 25.mm
           nbox_width = 135.mm - box_width
    pdf.text_box '-', :size => 10, :at => [37.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.text_box line.txt3.text + ':', :size => 10, :at => [40.mm,row_y_b], :width => box_width + 2.mm, :height => 5.mm
    pdf.spec_box line.txt5.text + '.', :size => 10, :at =>[nbox_x,row_y_b], :width => nbox_width, :height => 5.mm, :overflow => :expand

end

def rev_print_linetype_7_helper(line, row_y_b, pdf)
    pdf.text_box '-', :size => 10, :at => [37.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.spec_box line.txt4.text + '.', :size => 10, :at =>[40.mm,row_y_b], :width => 134.mm, :height => 5.mm, :overflow => :expand
end

def rev_print_linetype_8_helper(line, row_y_b, pdf)
    pdf.text_box '-', :size => 10, :at => [37.mm,row_y_b], :width => 3.mm, :height => 5.mm
    pdf.spec_box line.txt4.text + ': ' + line.txt5.text + '.', :size => 10, :at =>[40.mm,row_y_b], :width => 134.mm, :height => 5.mm, :overflow => :expand
end


def clausetitle_continued(line, row_y_b, pdf)
     pdf.text_box 'Clause continued on next page...', :size => 9, :style => :italic, :at =>[20.mm,row_y_b], :width => 155.mm, :height => 5.mm, :overflow => :expand
end

def clausetitle_repeat(line, row_y_b, pdf)
     pdf.text_box line.clause.clauseref.subsection.section.ref + sprintf("%02d", line.clause.clauseref.subsection.ref).to_s + '.' + line.clause.clauseref.clausetype_id.to_s + sprintf("%02d", line.clause.clauseref.clause).to_s + line.clause.clauseref.subclause.to_s, :size => 10, :style => :bold_italic, :at =>[0.mm,row_y_b], :width => 20.mm, :height => 5.mm
     pdf.spec_box line.clause.clausetitle.text + ' (continued)', :size => 10, :style => :bold_italic, :at =>[20.mm,row_y_b], :width => 155.mm, :height => 5.mm, :overflow => :expand
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

#if @superseded[0].to_i == 1;
#  watermark_helper("superseded", pdf)
#end;


#  def watermark_helper(action, pdf)
#    pdf.repeat :all do
#      pdf.transparent(0.15) do
#        pdf.text_box action, :width => 250.mm, :size => 108, :style => :bold, :at => [20.mm,55.mm], :rotate => 60
#      end
#    end
#  end
   
end