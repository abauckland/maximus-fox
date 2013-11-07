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
##??amend to take account of productclauses table
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

#units in second header row or in cell?          
#          unit_list = Unit.all.collect{|m| m.text} #[" mm", " m ", " cm", " ft", " kg", " g ", " l ", " W ", " Pa "]
#          if unit_list.include?(cell.last)
#            @product_import_errors << ('Line ' << i.to_s  << ', cell '<<  n.to_s << ', Cell data error: space between units and number.')     
#          end
          
#          unit_list = Unit.all.collect{|m| m.text} #[" mm2", " m2 ", " cm2", " mm3" " m3", " cm3 ", " ft2"]
#          if unit_list.include?(cell.last)
#            @product_import_errors << ('Line ' << i.to_s  << ', cell '<<  n.to_s << ', Cell data error: define area using sqm, sq ft, etc.')     
#          end
          
          if cell.first != cell.first.capitalize
#what if numerical value?
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
#import errors
#re-calculate errors and print result
  
    @productimport_errors = params[:import_errors]
    prawnto :filename => "product_upload_error_log.pdf", :prawn => {:page_size => "A4", :margin => [20.mm, 14.mm, 5.mm, 20.mm], :font => 'Times-Roman'}, :inline=>false     
end



def csv_product_upload

  #get using paperclip
  #@csv = CSV.read("#{Rails.root}/public#{@csv.csv.url.sub!(/\?.+\Z/, '') }", {:headers => true, }) 

  #validate csv to check that correct columns are included and they are completed



    
    #line[0] = clause reference
    #line[1] = clausetitle
    #line[2] = subtitle (txt4)
    #line[3] = product reference
    #line[4] = product name
    
    #line[5] = item reference
    #line[6] = item name
    
  product_imports = Productimport.where('date_completed IS ?', nil)
  
  product_imports.each do |product_import|
  
    csv = CSV.read(product_import.csv.url)
    csv_numrows = (csv.length) - 2

   
    headers = @csv[0]
    units = @csv[1]
    standards = @csv[1]
    line_array_length = headers.length    
#!!!!!!!!!!prepare line data    
  ##array of tx3_ids for headers
    line_array_length = headers.length
      
      header_txt3_id_array = [] 
      unit_id_array = [] 
      standard_id_array = [] 
             
      (7..line_array_length).each do |i|        

        header_txt3_check = Txt3.find_or_create_by_text(headers[i])
        #header_txt3_check = Txt3.where(:text => headers[i]).first_or_create
        header_txt3_id_array[i] = header_txt3_check.id
        #starts from 7...

        unit_check = Unit.find_or_create_by_text(units[i])
        #unit_check = Unit.where(:text => units[i]).first_or_create
        unit_id_array[i] = unit_check.id
        #starts from 7...
        
        standard_check = Standard.find_or_create_by_text(standards[i])
        #unit_check = Unit.where(:text => units[i]).first_or_create
        standard_id_array[i] = standard_check.id
        #starts from 7...
        
      end      


    csv(3..csv_numrows).each do |line|  

            
  ##find or create txt4 record for clause substitle    
      subtitle_check = Txt4.find_or_create_by_text(line[2])
      #subtitle_check = Txt4.where(:text => line[2]).first_or_create

  ##check if product group exists
        #find or create product group
        check_productgroup = Productgroup.joins(:productclauses).where(
          :company_id => current_user.company_id,
          :txt4_id => subtitle_check,
          :ref => line[3],
          :name => line[4]
        ).first
              
        if check_productgroup.blank?
          check_productgroup = Productgroup.create(
            :company_id => current_user.company_id,
            :txt4_id => subtitle_check,
            :ref => line[3],
            :name => line[4]
          ).first
          #remove any productgroups not updated - record change          
        end

  ##check if product item exists
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
          #record change        
        end 


  ##check if product assigned to clause

  ##find clause_id - clauseref and clause title (checked that it exists on uploaed)
      #private method
      clause_check(line[0], line[1])

      check_product_clause = Productclause.where(:product_id => check_productgroup, :clause_id => clause_check.id).first
      if check_product_clause
        check_product_clause = Productclause.create(:product_id => check_productgroup, :clause_id => clause_check.id) 
      end



#!!!!!!!!!find or create performance records for line
        line_txt6 = line.drop(7)
        
        performance_pairs = []
        line_txt6.each do |txt6_text, i|

          txt6 = Txt6.find_or_create_by_text(txt6_text)
          
          
          txt3_id = header_txt3_id_array[i]
          unit_id = unit_id_array[i]
          standard_id = standard_id_array[i]

          txt6unit = Txt6unit.find_or_create(:txt6_id => txt6.id, :unit_id => unit_id, :standard_id => standard_id)
          
           performance_pair = Performtxt6unit.includes(:performance).where(:txt6unit_id => txt6unit.id, 'performances.txt3_id' => txt3_id).first
           if performance_pair.blank?
             performance_ref = Performance.create(:txt3_id => txt3_id)
             performance_pair = Performtxt6unit.create(:performance_id=> performance_ref.id, :txt6unit_id => txt6unit.id)
           end
           performance_pairs[i] = performance_pair.id

        end   

##check if product has values not in current product data upload
        performance_pairs = performance_pairs.sort
        existing_product_performance_pairs = Characteritic.where(:product_id => check_product.id).collect{|i| i.performance_id}.sort
        
        if existing_product_performance_pairs.blank?
          performance_pairs.each do |pair|
            product_charactistic_check = Characteristic.create(:product_id => check_product.id, :performance_id => pair)
            #record change          
          end                
        else
          if performance_pairs == existing_product_performance_pairs
            #record change
          else
            old_pairs_no_listed = existing_product_performance_pairs.delete_if{|x| performance_pairs.includes?(x)}
            if old_pairs_no_listed
              #delete old records not in current upload
              if params[:action] == 'overwrite'
                old_pairs_no_listed.each do |pair|
                  product_charactistic_check = Characteristic.delete(:product_id => check_product.id, :performance_id => pair).first
                end
              end
              #record change
            end
            new_pairs_no_listed = performance_pairs.delete_if{|x| existing_product_performance_pairs.includes?(x)}
            if new_pairs_no_listed
              #add new reords not in existing database
              if params[:action] == 'overwrite'
                new_pairs_no_listed.each do |pair|
                  product_charactistic_check = Characteristic.create(:product_id => check_product.id, :performance_id => pair)
                end
              end
              #record change            
            end  
          end
        end



  ##if overwrite existing, delete all records with time less than last completed upload for the company 
      if params[:action] == 'overwrite'
        #find all product groups, products, characteristics for company that have not been updated
        #delete
        
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



private

def clause_check(clauseref, clausetitle)
#!!! 'dot' in clause reference not accounted for
  clause_check = Clause.joins(:clausetitle, :clauseref => [:subsection => [:section]]).where('section.ref = ? AND subsection.ref = ? AND clauseref.clausetype_id = ? AND clauseref.clause =? AND clauseref.subclause = ? AND clausetitle.text', clauseref[0], clauseref[1..2], clauseref[3], clauseref[4], clauseref[5..6], clausetitle).first  
end


def productgroup_delete(productgroup)
  
  #find all products and move
#mark as superseded or   
#do by date or revision number?
  old_productgroups = Productgroup.where(:company_id => current_user.company_id, :updated => time_ago_in_words(Date.today - 2))
  old_productgroups.each do |product_group|
    add_old_productgroup = Changedproductgroup.create(product_group)
    
  end
#find all productclauses and move
#find all characteristics and move
#find all unused performance pairs and move
  
end

def product_delete(product)
  
end

def productclause_delete(productclause)
  
end

def characteristic_delete(characteristic)
  
end


    
end
