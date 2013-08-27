class ProductimportsController < ApplicationController

before_filter :require_user

layout "products"


def new
  @productimport = Productimport.new
  
  
  @product_import_queue = Productimport.joins(:user).where('users.company_id = ? AND date_completed IS ?', current_user.company_id, nil).order('created_at')
  @product_import_history = Productimport.joins(:user).where('users.company_id = ? AND date_completed IS NOT ?', current_user.company_id, nil).order('created_at')

end


def create
  @productimport = Productimport.new(params[:productimport])
    
  require 'csv'
  
  @csv = CSV.read(params[:productimport][:csv].path)   
  headers = @csv[0]

  
  @product_import_errors = []
  #check no header values are nil
  if headers.include?(nil)
    missing_header_count = headers.length - headers.compact.length
        @product_import_errors << (missing_header_count.to_s << ' column heading(s) are blank, please ensure that all columns have a header title')   
  end
  
  
  #check fixed headers are correct
  check_array = ['Clause Ref','Subtitle','Product Ref','Product Name','Item Ref', 'Item Name']
  check_header_array = headers[0..5]   
  if check_array != check_header_array
       @product_import_errors << ('Compulsory columns are not correct, they are either missing, in the incorrect order or misspelt. Please correct errors and reload file.')
  end
  
  @csv_no_headers = @csv.drop(1)
  
  if !@csv_no_headers.empty?
    if @productimport.empty?
    
      #check if clause references are valid for each line
      #if clause.blank?      
        @csv_no_headers.each_with_index do |line, i| 
          #private method
          clause_check(line[0], line[1])                 
          if check_clause.blank?      
            @product_import_errors << ('Clause reference' << line[0].to_s << 'does not exist.') 
          end
        end
      #end

      @csv.each_with_index do |line, i|    
        line.each_with_index do |cell, n|

          if cell.strip! != nil
            @product_import_errors << ('Line ' << i.to_s << ', cell '<< n.to_s << ', Cell data error: white space before and, or, after text.')     
          end
          
          punt_list = [".", ",", ";", ":", "!", "?", "/", "'"]
          if punt_list.include?(cell.last)
            @product_import_errors << ('Line ' << i.to_s  << ', cell '<<  n.to_s << ', Cell data error: punctuation after text.')     
          end
          
          unit_list = [" mm", " m ", " cm", " ft", " kg", " g ", " l ", " W ", " Pa "]
          if unit_list.include?(cell.last)
            @product_import_errors << ('Line ' << i.to_s  << ', cell '<<  n.to_s << ', Cell data error: space between units and number.')     
          end
          
          unit_list = [" mm2", " m2 ", " cm2", " mm3" " m3", " cm3 ", " ft2"]
          if unit_list.include?(cell.last)
            @product_import_errors << ('Line ' << i.to_s  << ', cell '<<  n.to_s << ', Cell data error: define area using sqm, sq ft, etc.')     
          end
          
          if cell.first != cell.first.capitalize
            @product_import_errors << ('Line ' << i.to_s  << ', cell '<<  n.to_s << ', Cell data error: first letter must be a capital letter.')     
          end
          #degrees and other sufixes          
        end   
      end
    
    end
  end

  
  respond_to do |format|
    if @product_import_errors.empty?   
      @productimport.save
      flash[:notice] = 'CSV uploaded successfully.'
      format.html { render :action => "new" }
      #format.xml  { render :xml => @company, :status => :created, :location => @company }
    else
      format.html { render :action => "new" }
      format.xml  { render :xml => @product_import_errors, :status => :unprocessable_entity }
    end
  end  
end




def product_error_print
    @productimport_errors = params[:import_errors]
    prawnto :filename => "product_upload_error_log.pdf", :prawn => {:page_size => "A4", :margin => [20.mm, 14.mm, 5.mm, 20.mm], :font => 'Times-Roman'}, :inline=>false     
end



def csv_product_upload
    
    #line[0] = clause reference
    #line[1] = clausetitle
    #line[2] = clause substitle
    #line[3] = product reference
    #line[4] = product name
    #line[5] = item reference
    #line[6] = item name
    
  product_imports = Productimport.where('date_completed IS ?', nil)
  
  product_imports.each do |product_import|
  
    csv = CSV.read(product_import.csv.url, headers: true)
    csv.each do |line| 

#!!!!!!!!!!clean each line entry

    
  ##array of tx3_ids for headers
    line_array_length = line.length
      
      header_txt3_id_array = []        
      (7..line_array_length).each do |i|        

        header_txt3_check = Txt3.find_or_create_by_text(headers[i])
        #header_txt3_check = Txt3.where(:text => headers[i]).first_or_create
        header_txt3_id_array[i] = header_txt3_check.id
        #starts from 7...
      end      
      #erase nil records from start of array 0..6
      header_txt3_id_array.compact
    
   
  ##find clause_id if it exists - clauseref and clause title
      #private method
      clause_check(line[0], line[1])
            
  ##find or create txt4 record for clause substitle    
      subtitle_check = Txt4.find_or_create_by_text(line[2])
      #subtitle_check = Txt4.where(:text => line[2]).first_or_create
      
  ##find or create performance records for line   
      #array to save performance_ids in
      performance_id_array = [] 
       
      (7..line_array_length).each do |i|
                     
        txt6_check = Txt6.find_or_create_by_text(line[i])
        #txt6_check = Txt6.where(:text => line[i]).first_or_create        

        performance = Performances.includes(:txt3).where(txt3_id => header_txt3_id_array[i], txt6_id => txt6_check.id).first
        performance_id_array[i] = performance.id          
      end       
      performance_id_array.compact

  ##check if product for company with same performance critria exists
      #!! and check other attributes to ensure is the same product
      product_check = Product.joins(:characteristics, :productgroup).where(
        'productgroups.company_id' => current_user.company_id,
        'productgroups.clause_id' => clause_check.id,
        'productgroups.txt4_id' => subtitle_check,
        'productgroups.ref' => line[3],
        'productgroups.name' => line[4],
        :ref => line[5],
        :name => line[6],
        'characteristics.performance_id' => performance_id_array
      ).first
      
      
      if product_check
        #if exists update checked date
        product_check.updated_at = Time.now
        product.save  
      else    
        #if does not exist create new product record
        
        #find or create product group
        check_productgroup = Productgroup.where(
          :company_id => current_user.company_id,
          :clause_id => clause_check.id,
          :txt4_id => subtitle_check,
          :ref => line[3],
          :name => line[4]
        ).first
              
        if check_productgroup.blank?
          check_productgroup = Productgroup.create(
            :company_id => current_user.company_id,
            :clause_id => clause_check.id,
            :txt4_id => subtitle_check,
            :ref => line[3],
            :name => line[4]
          ).first          
        end
        
        
        #find or create product
        check_product = Product.where(
          :productgroup_id => check_productgroup.id,
          :ref => line[5],
          :name => line[6]
        ).first
        
        if check_product.blank?
          check_product = Product.create(
            :productgroup_id => check_productgroup.id,
            :ref => line[5],
            :name => line[6]
          ).first        
        end        

        #create characteristics record
        performance_id_array.each do |perform_id|
          add_characteristic = Characteristic.create(:product_id => check_product.id, :performance_id => perform_id)
        end               
      end   
 
  ##if overwrite existing, delete all records with time less than last completed upload for the company 
      if params[:action] == 'overwrite'
        #find all products to be deleted
        
        #create relevant productgroups in archive
        #copy all products selected to archive
        #find all characteristics and copy to archive
        
        #delete all characteristics for each product
        #delete all products selected
        
        #find all productgroups without products and delete
      end

    #end to each csv line
    end
  #end to each csv file to be uploaded   
  end
end




def product_specline_update
   
  Project.all.each do |project|
            
  ##get clause in project with speclines that have data      
    clauses_ids = Clause.joints(:speclines).where('speclines.project_id = ?  AND speclines.linetype_id = ?', project.id, 5).collect{|i| i.id}

    
    clauses_ids.each do |clauses_id|
  
  ##get relevant speclines for clause
      clause_speclines = Specline.where(:project_id => project.id, :clause_id => clause.id, :linetype => 5).order('clauseline')    

  ##is line before a subtitle?  
      preceding_clauseline = clause_speclines.first.clauseline - 1
      subtitle_check = Specline.where(:project_id => project.id, :clause_id => clause.id, :linetype => 7, :clauseline => preceding_clauseline).first
      if subtitle_check
        subtitle_id = subtitle_check.txt4_id
      end

  ##find next substitle or end of product attributes
      used_clauselines = clause_speclines.collect{|i| i.clauseline}
      
      used_clauselines.each_with_index do |line_number, i|
      
      
      
      end
      ##check linetype of intermediate lines
      subtitle_check = Specline.where(:project_id => project.id, :clause_id => clause.id, :clauseline => preceding_clauseline).first
      
      
  ##check all attributes (linetypes 5 & 6)
  
  
  ##check only linietype 5 attributes

      


  ##for product speclines get performance pairs
      find_current_performance_pairs(product_speclines)
  
  ##test is product exists
      product_check = Product.joins(:characteristics, :productgroup).where(
        'productgroups.company_id' => company_id,
        'productgroups.clause_id' => clauses_id,
        'productgroups.txt4_id' => subtitle_id,
        'characteristics.performance_id' => performance_id_array
      ).first
      
  ##if product does not exist
      if product_check      
      ##find attributes that are not correct
    
  
  
      end
    
    #end to each clause of project
    end    
  #end to each project    
  end   
end




private

def find_current_performance_pairs(product_speclines)

  performance_id_array = []
  txt3_array = []
  i = 0
  product_speclines.each do |specline|
    i = i + 1  
    
    txt6_string = specline.txt6.text
    #check for value arrays in txt6_id 
    if txt6_string.includes?(',','and')
      #split string into an array
      txt6_string['and'] = ','
      split_txt6_array = txt6_string.split(/,/)
      
      split_txt6_array.each do |text|
        i = i + 1 
        text.strip
        find_create_txt6(text)
        #search performance ids
        txt3_text_array(specline.txt3_id, txt6_id, i)         
      end      
    else
      #search performance ids
      txt3_text_array(specline.txt3_id, specline.txt6_id, i)       
    end
  end
end


def txt3_text_array(txt3_id, txt6_id, i)
  performance = Performances.includes(:txt3).where(txt3_id => txt3_id, txt6_id => txt6_id).first
  performance_id_array[i] = performance.id        
  txt3_array[i] = performance.txt3.text
  txt3_array.compact  
end


def clause_check(clauseref, clausetitle)
  clause_check = Clause.joins(:clausetitle, :clauseref => [:subsection => [:section]]).where('section.ref = ? AND subsection.ref = ? AND clauseref.clausetype_id = ? AND clauseref.clause =? AND clauseref.subclause = ? AND clausetitle.text', clauseref[0], clauseref[1..2], clauseref[3], clauseref[4], clauseref[5..6], clausetitle).first  
end

    
end
