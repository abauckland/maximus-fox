class ProductimportsController < ApplicationController

before_filter :require_user

layout "products"

  def new
    @productimport = Productimport.new
    
    @product_import_queue = Productimport.joins(:user).where('users.company_id = ? AND date_completed IS ?', current_user.company_id, nil).order('created_at')
    @product_import_history = Productimport.joins(:user).where('users.company_id = ? AND date_completed IS NOT ?', current_user.company_id, nil).order('created_at')

  end

def create
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
    
  @productimport = Productimport.new(params[:productimport])
    
  require 'csv'
  
  @csv = CSV.read(params[:productimport][:csv].path) 
  headers = @csv[0]
  units = @csv[1]
  standards = @csv[2]
  
  @product_import_errors = []

  #check if header, units and standards rows
  if @csv.length <= 3
    @product_import_errors << ('insufficient data in uploaded file')     
  else
    
    #check no header values are nil
    missing_header_count = headers.length - headers.compact.length
    if missing_header_count >= 1
   # if headers.include?(nil)
      @product_import_errors << (missing_header_count.to_s << ' column heading(s) are blank, all columns must have a title')   
    end

    #check fixed headers are correct
    if headers[0].downcase != 'clause ref'
      @product_import_errors << ('please make sure first column is titled "clause ref"')    
    end
  
    if headers[1].downcase != 'clause title'
      @product_import_errors << ('please make sure first column is titled "clause title"')    
    end
  
    if headers[2].downcase != 'product type'
      @product_import_errors << ('please make sure first column is titled "product type"')    
    end
  
    #check unit headers are units
    units.each_with_index do |unit, i|
      if unit
        check_unit = Unit.where(:ref => unit).first
        if !check_unit
          @product_import_errors << ('"'<< check_unit.text.to_s << '" not recognised as a unit in column ' << i.to_s)
        end
      end  
    end
  
    #check standard refs are standards
    standards.each_with_index do |standard, i|
      if standard
        check_standard = Standard.where(:ref => standard).first
        if !check_standard
          @product_import_errors << ('"'<< standard.to_s << '" not recognised standard in column ' << i.to_s)
        end
      end     
    end

    if !@product_import_errors.any?
      last_row_of_data = (@csv.length - 1)
      
      (3..last_row_of_data).each do |i| 
        
        line = @csv[i]

        if line[0].to_s.length <= 6
          @product_import_errors << ('Full clause reference must be included in row ' << i.to_s) 
        else
          if line[1].to_s.length <= 1
            @product_import_errors << ('Clause title must be included in row ' << i.to_s) 
          else
            clauseref = line[0].to_s
            clausetitle = line[1].to_s 
            
            clause_check = Clause.joins(:clausetitle, :clauseref => [:subsection => [:section]]).where('sections.ref' => clauseref[0], 'subsections.ref' => clauseref[1..2],'clauserefs.clausetype_id' => clauseref[4], 'clauserefs.clause' => clauseref[5..6], 'clauserefs.subclause' => clauseref[7], 'clausetitles.text' => clausetitle).first  
     
            if clause_check.blank?      
              @product_import_errors << ('Clause reference "' << clauseref[1..2] << '" is not valid') 
            end              
          end
        end
        
        if line[2].to_s.length <= 1
          @product_import_errors << ('Product type "' << i.to_s << '" must be stated')
        else        
          check_product_type = Producttype.where(:text => line[2]).first      
          if !check_product_type
            @product_import_errors << ('"'<< line[2].to_s << '" not recognised product type in column ' << i.to_s)
          end                      
        end
        
      end
    end  
  end

 
  respond_to do |format|
    if @product_import_errors.empty?   
      
      csv_product_upload(@csv, units, standards, headers)
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

private

def csv_product_upload(csv, units, standards, headers)
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
  #product_imports = Productimport.where('date_completed IS ?', nil)
  
#process each csv file
  #product_imports.each do |product_import|
  
    #read csv file
    #csv = CSV.read(product_import.csv.url)
    #count total number of rows of product data
    
    
    #find where 'instance' column is
    instance_column = headers.index('instance')
    #find range of headers with identity keys
    identity_headers_range = [3..(instance_column - 1)]    

    #create array to hold encoded product information
    product_array = []
    
    #for each line of data    
      last_row_of_data = (csv.length - 1)
      (3..last_row_of_data).each do |i| 
        
        line = csv[i]
      #create array for each product line of clause ids

        #reference private method 'clause_check(clauseref, clausetitle)'
        clauseref = line[0].to_s
        clausetitle = line[1].to_s 
        clause_check = Clause.joins(:clausetitle, :clauseref => [:subsection => [:section]]).where('sections.ref' => clauseref[0], 'subsections.ref' => clauseref[1..2],'clauserefs.clausetype_id' => clauseref[4], 'clauserefs.clause' => clauseref[5..6], 'clauserefs.subclause' => clauseref[7], 'clausetitles.text' => clausetitle).first 
        product_array[0] = clause_check.id

      #create array for each product line of product type ids
        
        producttype = Producttype.where(:text => line[2]).first_or_create
        product_array[1] = producttype.id
      #create array for each product line of identity pair ids
        identity_pair_array = []
        (3..(instance_column - 1)).each do |n|
            
            identity_key = Identkey.where(:text => headers[n]).first_or_create
            
            if line[n].to_s.length >= 1
              if headers[n] === "manufacturer"              
                @product_company = Company.where(:company_name => line[n]).first              
                identity_value = Identvalue.where(:company_id => @product_company.id).first_or_create              
              else              
                identity_text = Identtxt.where(:text => line[n]).first_or_create
                identity_value = Identvalue.where(:identtxt_id => identity_text.id).first_or_create
              end              
              identity_pair = Identity.where(:identkey_id => identity_key.id, :identvalue_id => identity_value.id).first_or_create
              identity_pair_array[n] = identity_pair.id
              identity_pair_array = identity_pair_array.compact
            end
        end
        product_array[2] = identity_pair_array

      #create array for each product line of instance ids
        #not used, included for consistency
        product_array[3] = line[instance_column]    
      
      #create array for each product line of peform pair ids
        perform_pair_array = []
        ((instance_column + 1)..(headers.length - 1)).each do |m|
            
            #find or create perform pair key
            perform_key = Performkey.where(:text => headers[m]).first_or_create
            
            #find or create perform pair value
            if line[m].to_s.length > 0
              performtxt = Performtxt.where(:text => line[m]).first_or_create
            
                        
              if units[m].to_s.length > 0
                unit = Unit.where(:ref => units[m]).first_or_create
                unit_id = unit.id
              else
                unit_id = nil
              end
            
              if standards[m].to_s.length >= 1
                standard = Standard.where(:ref => standards[m]).first
                standard_id = standard.id
              else
                standard_id = nil
              end
                                                         
              #note performvalue is not is not unique, only unique when combined with performvalue array
              #need to check if combined performvalue and performtxtarray exist 
              value_type = Valuetype.where(:unit_id => unit_id, :standard_id => standard_id).first_or_create
              perform_value = Performvalue.where(:valuetype_id => value_type.id, :performtxt_id => performtxt.id).first_or_create          
                        
              perform = Perform.where(:performkey_id => perform_key.id, :performvalue_id => perform_value.id).first_or_create
            
              perform_pair_array[m] = perform.id
              perform_pair_array = perform_pair_array.compact
            end
            product_array[4] = perform_pair_array
         end
      


#=> for each row of product data
#=> [[clause_id], [producttype_id], [identity_pair_array], [instance],[perform_pair_array]]

##PERFORMANCE IMPROVEMENTS TO MAKE
#find or create units, standards and headers before iterating through lines - current finds or creates each for every line

#update product tables
         # product_array.each do |product|
        
            existing_product = Product.joins(:descripts => :identity).where('identities.id' => identity_pair_array).group('products.id')
            #check if product with matching identities exists
            if existing_product.empty?
              #create new product & instance thereof              
              create_new_product_and_instance(product_array)                         
            else
              count_existing_products = existing_product.count  
              #if product with some matching identity pairs exists
              #check if product with all identity pairs exists
              if count_existing_products.key(product_array[2].length)
                #if product with all identity exists (will get first in hash if more than one match)
                #check if product clause relationship exists
                #if product clause relationship does not exist create
                existing_product_id = count_existing_products.key(product_array[2].length)
                clauseproduct = Clauseproduct.where(:clause_id => product_array[0], :product_id => existing_product_id).first_or_create
#update time stamps?
                #check if instance of product with same peform pairs exists     
                update_create_instance(existing_product_id, product_array)          
              else
                #product_id = count_existing_products.key(existing_product.values.max)
                #get product with most identity value matches
#?????            update_product(product_array[0], product_array[1], product_array[2])


                #check if instance of product with same peform pairs exists     
                  existing_instance = Instance.joins(:product => [:descripts => [:identity => :identvalue]], :charcs => :perform).where('identvalues.company_id' => @product_company.id, 'performs.id' => product_array[4]).group('products.id')
                  count_existing_instances = existing_instance.count
                  if count_existing_instances.key(product_array[4].length).nil? 
                    create_new_product_and_instance(product_array)    
                  else  
                     #of there is a product match
                     #create new product
                     #update instance product_ref
                     instance_id = count_existing_instances.key(product_array[4].length)
                     create_new_product_update_existing_instance(instance_id, product_array)
                  end 
              end            
            end
            
         # end
      end
end


def create_new_product_and_instance(product_array)
    new_product = Product.create(:producttype_id => product_array[1])
    #set up product clause relationship
    new_clauseproduct = Clauseproduct.where(:clause_id => product_array[0], :product_id => new_product.id).create
    #link identity pairs with new product
    product_array[2].each do |identity_pair_id|
      new_descripts = Descript.where(:product_id => new_product.id, :identity_id => identity_pair_id).first_or_create
    end
    new_instance = Instance.create(:product_id => new_product.id, :code => product_array[3])
    #line perform pairs with new instance
    product_array[4].each do |perform_pair_id|
      new_charcs = Charc.where(:instance_id => new_instance.id, :perform_id => perform_pair_id).first_or_create
    end                   
end 


def update_create_instance(product_id, product_array)
  existing_instance = Product.joins(:instances => [:charcs => [:perform]]).where(:id => product_id, 'performs.id' => product_array[4]).group('products.id')

  if existing_instance.empty?
    create_product_instance(product_id, product_array)
  else
    #check if instance to all perform pairs exists
    count_existing_instances = existing_instance.count
    if count_existing_instances.key(product_array[4].length).nil?
      create_product_instance(product_id, product_array)
      #if exists do not alter
      #if does not exist, get id of instance with least number of perform pair matches, may only be one in hash
     # instance_id = existing_instance.key(existing_instance.values.min)
      #update instance
     # update_product_instance(instance_id, product_array)
    end  
  end
end


def create_product_instance(product_id, product_array)
    #instance code not unique
    new_instance = Instance.create(:product_id => product_id, :code => product_array[3])
    #line perform pairs with new instance
    product_array[4].each do |perform_pair_id|
      new_charcs = Charc.where(:instance_id => new_instance.id, :perform_id => perform_pair_id).first_or_create
    end         
end

def create_new_product_update_existing_instance(existing_instance_id, product_array)
    new_product = Product.create(:producttype_id => product_array[1])
    #set up product clause relationship
    new_clauseproduct = Clauseproduct.where(:clause_id => product_array[0], :product_id => new_product.id).create
    #link identity pairs with new product
    product_array[2].each do |identity_pair_id|
      new_descripts = Descript.where(:product_id => new_product.id, :identity_id => identity_pair_id).first_or_create
    end
    existing_instance = Instance.where(:id => existing_instance_id).first
    existing_instance.product_id = new_product.id
    existing_instance.save                  
end 

  
#class end
end