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
#            @product_import_errors << ('Line ' << i.to_s  << ', cell '<<  n.to_s << ', Cell data error: define area using sq m, sq ft, etc.')     
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

#csv import file structure
#column structure
    # => line[0] = clauseref
    # => line[1] = clausetitle
    # => line[2] = producttype
    #----------------------------    
    # =>        identity_keys (manufacturer, product reference, product name)
    #----------------------------
    # =>        instance
    #----------------------------    
    # =>        perform_keys

#row structure
    #row 1 => headers, identity keys, perform keys
    #row 2 => units
    #row 3 => standard references
    #row 4+ => product data
 
    
  #get all name of csv files to be imported  
  product_imports = Productimport.where('date_completed IS ?', nil)
  
#process each csv file
  product_imports.each do |product_import|
  
    #read csv file
    csv = CSV.read(product_import.csv.url)
    #count total number of rows of product data
    csv_numrows = (csv.length) - 3

   
    headers = @csv[0]
    
    units = @csv[1]
     # units.each_with_index do |u, i|
      #  if units[i].empty?
      #    next
      #  else
      #    unit = Unit.where(:text => units[i]).first_or_create
      #    units[i] = unit.id
      #  end
      #end
    
    standards = @csv[2]
      #standards.each_with_index do |s, i|
      #  if standards[i].empty?
      #    next
       # else
       #   standard = Standard.where(:text => standards[i]).first_or_create
       #   standards[i] = standard.id
       # end
      #end

    
    ##count total number of columns (no headers should be empty - checked on preload)
    #header_array_length = headers.length    
    
    #find where 'instance' column is
    instance_column = headers.index('instance')
    #find range of headers with identity keys
    indentity_headers_range = [4..(instance_column - 1)]    
    #find range of headers with perform keys
    perform_headers_range = [(instance_column + 1)..headers.length]

#create array to hold encoded product information
    product_array = []
    
    #for each line of data
      csv(4..csv_numrows).each do |line|
      #create array for each product line of clause ids

        #reference private method 'clause_check(clauseref, clausetitle)'
        clause_check(line[0], line[1]) 
        product_array[0] = clause_check.id

      #create array for each product line of product type ids
        product_array[1] = Producttype.where(:text => line[2]).first_or_create
      
      #create array for each product line of identity pair ids
        identity_pair_array = []
        (identity_headers_range).each do |i|
            
            identity_key = Identkey.where(:text => headers[i]).first_or_create
            
            if headers[i].downcase! == 'manufacturer'
              product_company = Company.where(:name => line[i]).first              
              identity_value = Identvalue.where(:company_id => product_company.id).first_or_create
            else
              identity_text = Identtxt.where(:text => line[i]).first_or_create
              identity_value = Identvalue.where(:identtxt_id => identity_text.id).first_or_create
            end  
            
            identity_pair = Identity.where(:identkey_id => identity_key.id, :identvalue_id => identity_value.id).first_or_create
            identity_pair_array[i] = identity_pair.id

        end
        product_array[2] = identity_pair_array
      #create array for each product line of instance ids
        #not used, included for consistency
        product_array[3] = line[instance_column]
      
      #create array for each product line of peform pair ids
        perform_pair_array = []
        (perform_headers_range).each do |i|
            
            #find or create perform pair key
            perform_key = Performkey.where(:text => headers[i]).first_or_create
            
            #find or create perform pair value
            unit = Unit.where(:text => units[i]).first_or_create
            standard = Standards.where(:ref => standards[i]).first_or_create
            performtxt = Performtxt.where(:text => line[i]).first_or_create
                                              
            #note performvalue is not is not unique, only unique when combined with performvalue array
            #need to check if combined performvalue and performtxtarray exist 
            check_performa_value_id = Peformvalue.where(:unit_id => unit.id, :standard_id => standard.id).pluck(:id)            
            check_performtxtarray = Peformtxtarray.where(:performtxt_id => performtxt, :performvalue_id => check_performa_value_ids).first

            if check_performtxtarray
              performvalue_id = check_performtxtarray.performvalue_id
            else
                #if combined performvalue and performtxtarray does not exist create new
                new_performa_value = Peformvalue.create(:unit_id => unit.id, :standard_id => standard.id)
                new_performtxtarray = Peformtxtarray.create(:performtxt_id => performtxt, :performvalue_id => new_performa_value.id)
                performvalue_id = new_performtxtarray.id          
            end
            ###find or create perform pair
            
            peform = Perform.where(:performkey_id => perform_key.id, :performvalue_id => performvalue_id).first_or_create
            
            perform_pair_array[i] = perform_id
        end
        product_array[4] = perform_pair_array
      
      end
    #=> for each row of product data
    #=> [[clause_id], [producttype_id], [identity_pair_array], [instance],[perform_pair_array]]

##PERFORMANCE IMPROVEMENTS TO MAKE
#find or create units, standards and headers before iterating through lines - current finds or creates each for every line


#update product tables
    #check if product with all identity exists - identical match
    if product_match
      #check if product clause relationship exists
      #if product clause relationship does not exist create
      clauseproduct = Clauseproduct.create(:clause_id => product_array[0], :product_id => existing_product.id).first_or_create
      #update time stamps?
      
      #check if product exists check if instance of product with same peform pairs exists
      if instance_match
        #update time stamps?
      
      #if no instance of the product exists with the same peform pairs    
      else 
        #check if instances with some of the same, but no conflicting, perform values exists
        if instance_partial_match
          
        else
          #no instance with some of the same, but no conflicting, perform values exist
          #create instance
          create_new_product_instance(existing_product.id, product_array[4])
        end          
      end             
    #if no product with all identity exists - not an identical match    
    else
      #check if any products all of whose identity values match, but not all values are present
      if product_partial_match
    
      #if no products all of whose identity values match does not exist
      else
        #create new product
        create_new_product(product_array[0], product_array[1], product_array[2])
        #create new instance
        create_new_product_instance(new_product.id, product_array[4])
      end
    end
    
    
def create_new_product(clause_id, producttype_id, identity_pair_array)
    new_product = Product.create(:producttype_id => producttype_id)
    #set up product clause relationship
    new_clauseproduct = Clauseproduct.create(:clause_id => clause_id, :product_id => new_product.id)
    #link identity pairs with new product
    identity_pair_array.each do |identity_pair_id|
      new_descripts = Descript.create(:instance_id => new_instance.id, :perform_id => identity_pair_id)
    end         
end    

def create_new_product_instance(product_id, perform_pair_array)
    new_instance = Instance.create(:product_id => product_id)
    #lin perform pairs with new instance
    perform_pair_array.each do |perform_pair_id|
      new_charcs = Charc.create(:instance_id => new_instance.id, :perform_id => perform_pair_id)
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
