pdf.move_down(10.mm);if !@current_project.photo_file_name.blank?;  pdf.image "#{Rails.root}/public#{@company.photo.url.sub!(/\?.+\Z/, '') }", :position => :right, :vposition => -12.mm, :fit => [250,35];else  pdf.text "#{@current_project.client}", :size => 16, :style => :bold, :align => :right;end;pdf.text "#{@current_project.code} #{@current_project.title}", :size => 18, :style => :bold, :align => :right;pdf.text "Architectural Specification", :size => 16, :align => :right;pdf.text "Issue: #{@current_project.project_status}", :size => 16, :align => :right;pdf.text "Revision: #{@print_revision_rev}", :size => 16, :align => :right;pdf.move_down(10.mm);if !@company.photo_file_name.blank?;pdf.image "#{Rails.root}/public#{@current_project.photo.url.sub!(/\?.+\Z/, '') }", :position => :right, :vposition => :logo_bottom, :fit => [350,250];end;pdf.bounding_box([0,35 + 9.mm], :width => 176.mm, :height => 400) do;  pdf.text "#{@company.reg_name}", :size => 8, :align => :left;  pdf.text "Registered in #{@company.reg_location} No: #{@company.reg_number}", :size => 8, :align => :left;  pdf.text "#{@company.reg_address}", :size => 8, :align => :left;  pdf.text "#{@company.www} Tel: #{@company.tel}", :size => 8, :align => :left;end;pdf.start_new_page;pdf.move_down(11);pdf.text "Document Contents", :size => 16, :style => :bold;pdf.move_down(23);if !@revision_subsections.blank?;  pdf.text "Document Revisions", :size => 12, :leading => 2.mm;end;if !@current_prelim_subsections.blank?;  pdf.text "A-- Preliminaries", :size => 12, :leading => 2.mm;end;@current_none_prelim_subsections.each do |subsection|;  pdf.text "#{subsection.subsection_full_code_and_title}", :size => 12, :leading => 2.mm;end;if !@revision_subsections.blank?;pdf.start_new_page;@rev_start_bookmark = [];@rev_start_bookmark[0] = pdf.page_number;rev_row_y_b = 268.mm;pdf.text_box "Document Revisions", :size => 16, :style => :bold, :at => [0.mm,rev_row_y_b], :width => 100.mm, :height => 15.mm;rev_row_y_b = rev_row_y_b - 15.mm;if !@array_of_new_subsections_compacted.blank?;    pdf.text_box "Subsections added:", :size => 12, :style => :bold, :at => [0.mm,rev_row_y_b], :width => 50.mm, :height => 7.mm;  rev_row_y_b = rev_row_y_b - 7.mm;  if  @array_of_new_subsections_compacted.first.section_id == 1;         pdf.text_box "A-- Preliminaries:", :size => 11, :at => [5.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;      rev_row_y_b = rev_row_y_b - 6.mm;  end;  @array_of_new_subsections_compacted.each do |added_subsection|;          if  added_subsection.section_id == 1;         pdf.text_box "#{added_subsection.subsection_full_code_and_title}", :size => 10, :at => [10.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;      else;        pdf.text_box "#{added_subsection.subsection_full_code_and_title}", :size => 11, :at => [5.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;      end;      rev_row_y_b = rev_row_y_b - 6.mm;    end;      rev_row_y_b = rev_row_y_b - 4.mm;end;        if rev_row_y_b <= 53.mm;          pdf.start_new_page;          rev_row_y_b = 268.mm;        end;if !@array_of_deleted_subsections_compacted.blank?;    pdf.text_box "Subsections deleted:", :size => 12, :style => :bold, :at => [0.mm,rev_row_y_b], :width => 50.mm, :height => 7.mm;  rev_row_y_b = rev_row_y_b - 7.mm;  if  @array_of_deleted_subsections_compacted.first.section_id == 1;         pdf.text_box "A-- Preliminaries:", :size => 11, :at => [5.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;      rev_row_y_b = rev_row_y_b - 6.mm;  end;  @array_of_deleted_subsections_compacted.each do |subsection|;         if  subsection.section_id == 1;         pdf.text_box "#{subsection.subsection_full_code_and_title}", :size => 11, :at => [7.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;      else;        pdf.text_box "#{subsection.subsection_full_code_and_title}", :size => 11, :at => [5.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;      end;      rev_row_y_b = rev_row_y_b - 6.mm;    end;    rev_row_y_b = rev_row_y_b - 4.mm;end;        if rev_row_y_b <= 53.mm;          pdf.start_new_page;          rev_row_y_b = 268.mm;        end;if !@array_of_changed_subsections_compacted.blank?;    pdf.text_box "Subsections changed:", :size => 12, :style => :bold, :at => [0.mm,rev_row_y_b], :width => 50.mm, :height => 7.mm;  rev_row_y_b = rev_row_y_b - 7.mm;    if  @array_of_changed_subsections_compacted.first.section_id == 1;         pdf.text_box "A-- Preliminaries:", :size => 11, :at => [5.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;      rev_row_y_b = rev_row_y_b - 6.mm;    end;  @array_of_changed_subsections_compacted.each do |changed_subsection|;    if rev_row_y_b <= 47.mm;      pdf.start_new_page;      rev_row_y_b = 268.mm;    end;    if  changed_subsection.section_id == 1;       pdf.text_box "#{changed_subsection.subsection_full_code_and_title}", :size => 11, :at => [7.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;    else;      pdf.text_box "#{changed_subsection.subsection_full_code_and_title}", :size => 11, :at => [5.mm,rev_row_y_b], :width => 165.mm, :height => 6.mm;    end;    rev_row_y_b = rev_row_y_b - 6.mm;    if !@hash_of_deleted_clauses[changed_subsection.id].blank?;      pdf.text_box "Subsection clauses deleted:", :size => 11, :style => :bold, :at => [10.mm,rev_row_y_b], :width => 100.mm, :height => 6.mm;      rev_row_y_b = rev_row_y_b - 6.mm;      @hash_of_deleted_clauses_compacted = @hash_of_deleted_clauses[changed_subsection.id].compact;      @hash_of_deleted_clauses_compacted.each do |deleted_clause|;                pdf.text_box "#{deleted_clause.clause_code}", :size => 11, :at => [15.mm,rev_row_y_b], :width => 50.mm, :height => 5.mm;        pdf.text_box "#{deleted_clause.clausetitle.text}", :size => 11, :at => [35.mm,rev_row_y_b], :width => 50.mm, :height => 5.mm;        rev_row_y_b = rev_row_y_b - 5.mm;        if rev_row_y_b <= 12.mm;          pdf.start_new_page;          row_y_b = 268.mm;        end;                  end;      rev_row_y_b = rev_row_y_b - 4.mm;    end;      if rev_row_y_b <= 27.mm;      pdf.start_new_page;      rev_row_y_b = 268.mm;    end;    if !@hash_of_new_clauses[changed_subsection.id].blank?;      pdf.text_box "Subsection clauses added:", :size => 11, :style => :bold, :at => [10.mm,rev_row_y_b], :width => 100.mm, :height => 6.mm;      rev_row_y_b = rev_row_y_b - 6.mm;      @hash_of_new_clauses_compacted = @hash_of_new_clauses[changed_subsection.id].compact;      @hash_of_new_clauses_compacted.each do |new_clause|;         pdf.text_box "#{new_clause.clause_code}", :size => 11, :at => [15.mm,rev_row_y_b], :width => 135.mm, :height => 6.mm;        pdf.text_box "#{new_clause.clausetitle.text}", :size => 11, :at => [35.mm,rev_row_y_b], :width => 135.mm, :height => 5.mm;            rev_row_y_b = rev_row_y_b - 5.mm;        if rev_row_y_b <= 12.mm;          pdf.start_new_page;          rev_row_y_b = 268.mm;        end;          end;      rev_row_y_b = rev_row_y_b - 4.mm;    end;    if rev_row_y_b <= 47.mm;      pdf.start_new_page;      rev_row_y_b = 268.mm;    end;    if !@hash_of_changed_clauses[changed_subsection.id].blank?;      pdf.text_box "Subsection clauses changed:", :size => 11, :style => :bold, :at => [10.mm,rev_row_y_b], :width => 100.mm, :height => 5.mm;      rev_row_y_b = rev_row_y_b - 6.mm;      @hash_of_changed_clauses_compacted = @hash_of_changed_clauses[changed_subsection.id].compact;      @hash_of_changed_clauses_compacted.each do |changed_clause|;        if rev_row_y_b <= 40.mm;         pdf.start_new_page;         rev_row_y_b = 268.mm;       end;       pdf.text_box "#{changed_clause.clause_code}", :size => 11, :at => [15.mm,rev_row_y_b], :width => 50.mm, :height => 5.mm;       pdf.text_box "#{changed_clause.clausetitle.text}", :size => 11, :at => [35.mm,rev_row_y_b], :width => 50.mm, :height => 5.mm;       rev_row_y_b = rev_row_y_b - 6.mm;                    @deleted_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', @current_project.id, changed_clause, @selected_revision.id, 'deleted');        if !@deleted_lines.blank?;          pdf.text_box "Text deleted:", :size => 9, :style => :bold_italic, :at => [35.mm,rev_row_y_b], :width => 50.mm, :height => 5.mm;                rev_row_y_b = rev_row_y_b - 5.mm;                    @deleted_lines.each do |deleted_line|;			rev_line_print(deleted_line, rev_row_y_b, pdf);			rev_row_y_b = rev_row_y_b - pdf.box_height - 2.mm;                end;                    rev_row_y_b = rev_row_y_b - 2.mm;        end;        @added_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', @current_project.id, changed_clause, @selected_revision.id, 'new');        if !@added_lines.blank?;          pdf.text_box "Text added:", :size => 9, :style => :bold_italic, :at => [35.mm,rev_row_y_b], :width => 50.mm, :height => 5.mm;          rev_row_y_b = rev_row_y_b - 5.mm;                    @added_lines.each do |added_line|;      			rev_line_print(added_line, rev_row_y_b, pdf);			rev_row_y_b = rev_row_y_b - pdf.box_height - 2.mm;                                      end;          rev_row_y_b = rev_row_y_b - 2.mm;        end;        @changed_lines = Change.where('project_id = ? AND clause_id = ? AND revision_id =? AND event=?', @current_project.id, changed_clause, @selected_revision.id, 'changed');        if !@changed_lines.blank?;          check_changed_print_status = @changed_lines.collect{|item| item.print_change}.uniq;          if check_changed_print_status.include?(true);                  if rev_row_y_b <= 35.mm;              pdf.start_new_page;              rev_row_y_b = 268.mm;            end;            pdf.text_box "Text changed:", :size => 9, :style => :bold_italic, :at => [35.mm,rev_row_y_b], :width => 50.mm, :height => 5.mm;            rev_row_y_b = rev_row_y_b - 5.mm;                     @changed_lines.each do |changed_line|;                        rev_row_y_a = rev_row_y_b;            				rev_line_draft(changed_line, rev_row_y_a, pdf);  				rev_row_y_a = rev_row_y_a - pdf.draft_text_box_height - 2.mm;                                            subsequent_changes = Change.where('id > ? AND specline_id = ?', changed_line.id, changed_line.specline_id);              array_subsequent_changes = subsequent_changes.collect{|item| item.id};              subsequent_change = array_subsequent_changes[0];               if subsequent_changes.blank?;                line = Specline.find(changed_line.specline_id);              else;                line = Change.find(subsequent_change);                  end;                  				rev_line_draft(line, rev_row_y_a, pdf);				rev_row_y_a = rev_row_y_a - pdf.draft_text_box_height - 2.mm;                              rev_row_y_a =  rev_row_y_a - 8.mm;                            if rev_row_y_a >= 12.mm;                      rev_row_y_b = rev_row_y_b;                    else;                      pdf.start_new_page;                      rev_row_y_b = 268.mm;                    end;                    pdf.text_box "From:", :size => 8, :style => :italic, :at =>[35.mm,rev_row_y_b], :width => 20.mm, :height => 4.mm;              rev_row_y_b = rev_row_y_b - 4.mm;                				rev_line_print(changed_line, rev_row_y_b, pdf);				rev_row_y_b = rev_row_y_b - pdf.box_height - 2.mm;              pdf.text_box "To:", :size => 8, :style => :italic, :at =>[35.mm,rev_row_y_b], :width => 20.mm, :height => 4.mm;              rev_row_y_b = rev_row_y_b - 4.mm;                                 				rev_line_print(line, rev_row_y_b, pdf);           		rev_row_y_b = rev_row_y_b - pdf.box_height - 2.mm;                                 end;                  else;            pdf.text_box "Text changed:", :size => 9, :style => :bold_italic, :at => [35.mm,rev_row_y_b], :width => 50.mm, :height => 5.mm;            rev_row_y_b = rev_row_y_b - 4.mm;            pdf.text_box "Some minor spelling and grammatical changes have been made to this clause. For this reason revision details have not been recorded.", :size => 10, :style => :italic, :at =>[35.mm,rev_row_y_b], :width => 140.mm, :height => 5.mm, :overflow => :expand;            rev_row_y_b = rev_row_y_b - 10.mm;          end;        end;        rev_row_y_b = rev_row_y_b - 2.mm;      end;    end;  end;end;end;@rev_end_bookmark = [];@rev_end_bookmark[0] = pdf.page_number;@sub_start_bookmark = [];@sub_end_bookmark = [];if !@current_prelim_subsections.blank?;    pdf.start_new_page;    @sub_start_bookmark[0] = pdf.page_number;             pdf.text_box "A-- Preliminaries", :size => 16, :style => :bold, :at => [0.mm,268.mm], :height => 15.mm;        row_y_b = 260.mm;	@current_prelim_subsections.each do |subsection|;    if row_y_b <= 46.mm;     pdf.start_new_page;     row_y_b = 268.mm;    end;            clausetype_speclines = Specline.includes(:clause => [:clauseref]).where(:project_id => @current_project, 'clauserefs.subsection_id' => subsection.id).order('clauserefs.clause, clauserefs.subclause, clause_line'); 	prefixed_linetypes_array = Linetype.where(:txt1 => true).collect{|i| i.id};    	if !clausetype_speclines.blank?;    	clausetype_speclines.each_with_index do |line, i|;        		row_y_a = row_y_b;	@height_x = 0;		line_draft(line, row_y_a, pdf);	@height_x = pdf.draft_text_box_height;	if i == 0;		@height_x = @height_x + 16.mm	end;	if line.clause_line == 0;		@height_x = @height_x + 4.mm;		if !clausetype_speclines[i+1].blank?;			if prefixed_linetypes_array.include?(clausetype_speclines[i+1].linetype_id);				line_draft(clausetype_speclines[i+1], row_y_a, pdf);				@height_x = @height_x + pdf.draft_text_box_height;			else;				line_draft(clausetype_speclines[i+1], row_y_a, pdf);				@height_x = @height_x + pdf.draft_text_box_height;				if !clausetype_speclines[i+2].blank?;    								if prefixed_linetypes_array.include?(clausetype_speclines[i+2].linetype_id);						line_draft(clausetype_speclines[i+2], row_y_a, pdf);								@height_x = @height_x + pdf.draft_text_box_height;					end;				end;							end;				if clausetype_speclines[i+1].clause_line == 0;				@height_x = @height_x + 4.mm;				if !clausetype_speclines[i+2].blank?;    								if !prefixed_linetypes_array.include?(clausetype_speclines[i+2].linetype_id);						line_draft(clausetype_speclines[i+2], row_y_a, pdf);								@height_x = @height_x + pdf.draft_text_box_height;					else;						line_draft(clausetype_speclines[i+2], row_y_a, pdf);								@height_x = @height_x + pdf.draft_text_box_height;						if !clausetype_speclines[i+3].blank?;    										if prefixed_linetypes_array.include?(clausetype_speclines[i+3].linetype_id);								line_draft(clausetype_speclines[i+3], row_y_a, pdf);										@height_x = @height_x + pdf.draft_text_box_height;							end;						end;						end;				end;			end;		end;	end;	row_y_a = row_y_a - (@height_x);	if row_y_a >= 16.mm;    	if i == 0;    		row_y_b = row_y_b - 5.mm;			prelim_subsection_print(subsection, row_y_b, pdf, i);			row_y_b = row_y_b - 2.mm;		end;				if line.clause_line == 0;			row_y_b = row_y_b - 4.mm; 		else;			row_y_b = row_y_b - 2.mm; 				end;			line_print(line, row_y_b, pdf);		row_y_b = row_y_b - pdf.box_height;	 			else;		if line.clause_line == 0;			pdf.start_new_page;			row_y_b = 266.mm;			if i == 0;    			row_y_b = row_y_b - 6.mm;				prelim_subsection_print(subsection, row_y_b, pdf, i);				row_y_b = row_y_b - 2.mm;			end;			else;			row_y_b = row_y_b - 2.mm; 			clausetitle_continued(line, row_y_b, pdf);  			pdf.start_new_page;			row_y_b = 266.mm;			clausetitle_repeat(line, row_y_b, pdf);			row_y_b = row_y_b - pdf.box_height;		end;		row_y_b = row_y_b - 2.mm;		line_print(line, row_y_b, pdf);		row_y_b = row_y_b - pdf.box_height;		end;end;end;    		end;    @sub_end_bookmark[0] = pdf.page_number;end;@current_none_prelim_subsections.each_with_index do |subsection, n|;  pdf.start_new_page;  @sub_start_bookmark[n+1] = pdf.page_number;  pdf.text_box "#{subsection.section.ref}#{subsection.ref} #{subsection.text}", :size => 16, :style => :bold, :at => [0.mm, 268.mm], :height => 15.mm;  row_y_b = 262.mm;  clausetypes = Clausetype.includes(:clauserefs => [:subsection]).all;  prefixed_linetypes_array = Linetype.where(:txt1 => true).collect{|i| i.id};    clausetypes.each do |clausetype|;    if row_y_b <= 46.mm;     pdf.start_new_page;     row_y_b = 268.mm;    end;    clausetype_speclines = Specline.includes(:clause => [:clauseref]).where(:project_id => @current_project, 'clauserefs.subsection_id' => subsection.id, 'clauserefs.clausetype_id' => clausetype.id).order('clauserefs.clause, clauserefs.subclause, clause_line');if !clausetype_speclines.blank?;    	clausetype_speclines.each_with_index do |line, i|;        		row_y_a = row_y_b;	@height_x = 0;		line_draft(line, row_y_a, pdf);	@height_x = pdf.draft_text_box_height;	if i == 0;		@height_x = @height_x + 16.mm	end;	if line.clause_line == 0;		@height_x = @height_x + 4.mm;		if !clausetype_speclines[i+1].blank?;			if prefixed_linetypes_array.include?(clausetype_speclines[i+1].linetype_id);				line_draft(clausetype_speclines[i+1], row_y_a, pdf);				@height_x = @height_x + pdf.draft_text_box_height;			else;				line_draft(clausetype_speclines[i+1], row_y_a, pdf);				@height_x = @height_x + pdf.draft_text_box_height;				if !clausetype_speclines[i+2].blank?;    								if prefixed_linetypes_array.include?(clausetype_speclines[i+2].linetype_id);						line_draft(clausetype_speclines[i+2], row_y_a, pdf);								@height_x = @height_x + pdf.draft_text_box_height;					end;				end;							end;				if clausetype_speclines[i+1].clause_line == 0;				@height_x = @height_x + 4.mm;				if !clausetype_speclines[i+2].blank?;    								if !prefixed_linetypes_array.include?(clausetype_speclines[i+2].linetype_id);						line_draft(clausetype_speclines[i+2], row_y_a, pdf);								@height_x = @height_x + pdf.draft_text_box_height;					else;						line_draft(clausetype_speclines[i+2], row_y_a, pdf);								@height_x = @height_x + pdf.draft_text_box_height;						if !clausetype_speclines[i+3].blank?;    										if prefixed_linetypes_array.include?(clausetype_speclines[i+3].linetype_id);								line_draft(clausetype_speclines[i+3], row_y_a, pdf);										@height_x = @height_x + pdf.draft_text_box_height;							end;						end;						end;				end;			end;		end;	end;	row_y_a = row_y_a - (@height_x);	if row_y_a >= 17.mm;    	if i == 0;    		row_y_b = row_y_b - 5.mm;			clausetype_print(subsection, clausetype, row_y_b, pdf);			row_y_b = row_y_b - 2.mm;		end;				if line.clause_line == 0;			row_y_b = row_y_b - 4.mm; 		else;			row_y_b = row_y_b - 2.mm;		end;		 			line_print(line, row_y_b, pdf);		row_y_b = row_y_b - pdf.box_height;			else;		if line.clause_line == 0;			pdf.start_new_page;			row_y_b = 266.mm;			if i == 0;				clausetype_print(subsection, clausetype, row_y_b, pdf);				row_y_b = 256.mm;			end;			else;			row_y_b = row_y_b - 2.mm; 			clausetitle_continued(line, row_y_b, pdf);  			pdf.start_new_page;			row_y_b = 266.mm;			clausetitle_repeat(line, row_y_b, pdf);			row_y_b = row_y_b - pdf.box_height;		end;		row_y_b = row_y_b - 2.mm;		line_print(line, row_y_b, pdf);		row_y_b = row_y_b - pdf.box_height;		end;end;end;   	end;  @sub_end_bookmark[n+1] = pdf.page_number;end;pdf.line_width(0.1);date = @selected_revision.created_at;reformated_date = date.strftime("#{date.day.ordinalize} %b %Y");pdf.repeat :omit_first_page do;    pdf.stroke do;      pdf.line [0.mm,9.mm],[176.mm,9.mm];    end;    pdf.text_box "#{@current_project.code}  Revision: #{@print_revision_rev}.", :size => 8, :at => [0,pdf.bounds.bottom + 7.mm];    pdf.text_box "Created: #{reformated_date}", :size => 8, :at => [0,pdf.bounds.bottom + 3.mm];    pdf.text_box "#{@current_project.title}", :size => 9, :at => [0,pdf.bounds.top + 5.mm];    if !@company.photo_file_name.blank?;      pdf.image "#{Rails.root}/public#{@company.photo.url.sub!(/\?.+\Z/, '') }", :position => :right, :vposition => -11.mm, :align => :right, :fit => [250,25];    end;    pdf.stroke do;      pdf.line [0.mm,273.mm],[176.mm,273.mm];    end;end;if !@revision_subsections.blank?;  a = @rev_start_bookmark[0].to_i;  b = @rev_end_bookmark[0].to_i;  actual_page_count = b - a + 1;  pdf.repeat(:all, :dynamic => true) do;    actual_page_number = pdf.page_number - a + 1;    if actual_page_number >= 1;      if actual_page_number <= actual_page_count;        pdf.text_box "Rev #{actual_page_number}/#{actual_page_count}", :size => 8, :align => :right, :at => [158.mm,7.mm];      end;    end;  end;end;  @current_prelim_subsections.each_with_index do |subsection, i|;  c = @sub_start_bookmark[0].to_i;  d = @sub_end_bookmark[0].to_i;  actual_sub_page_count = d - c + 1;  pdf.repeat(:all, :dynamic => true) do;    actual_sub_page_number = pdf.page_number - c + 1;    if actual_sub_page_number >= 1;      if actual_sub_page_number <= actual_sub_page_count;      pdf.text_box "A-- Preliminaries", :size => 8, :align => :right, :at => [100.mm,7.mm];      pdf.text_box "Page #{actual_sub_page_number} of #{actual_sub_page_count}", :size => 8, :align => :right, :at => [150.mm,3.mm];        pdf.stroke do;          pdf.line [0.mm,273.mm],[176.mm,273.mm];        end;      end;    end;  end;  end;  @current_none_prelim_subsections.each_with_index do |subsection, i|;  c = @sub_start_bookmark[i+1].to_i;  d = @sub_end_bookmark[i+1].to_i;  actual_sub_page_count = d - c + 1;  pdf.repeat(:all, :dynamic => true) do;    actual_sub_page_number = pdf.page_number - c + 1;    if actual_sub_page_number >= 1;      if actual_sub_page_number <= actual_sub_page_count;      pdf.text_box "#{subsection.section.ref}#{subsection.ref} #{subsection.text}", :size => 8, :align => :right, :at => [100.mm,7.mm];      pdf.text_box "Page #{actual_sub_page_number} of #{actual_sub_page_count}", :size => 8, :align => :right, :at => [150.mm,3.mm];        pdf.stroke do;          pdf.line [0.mm,273.mm],[176.mm,273.mm];        end;      end;    end;  end;  end;if @watermark[0].to_i == 1;  watermark_helper("not for issue", pdf)end;if @superseded[0].to_i == 1;  watermark_helper("superseded", pdf)end;