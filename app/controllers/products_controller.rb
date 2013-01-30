class ProductsController < ApplicationController

before_filter :require_user


layout "suppliers"

def index
  current_user = User.first
  
  @txt3_id_array = Txt3.joins(:performances => [:characteristics => [:product => [:productgroup]]]).where('productgroups.supplier_id' => 1).order('text')
  
  @products = Product.includes(:productgroup =>[:txt4, :supplier, :clause => [:clausetitle]]).where('productgroups.supplier_id' => 1).order('productgroups.clause_id', 'productgroup_id')

end

def new
  @product = Product.new
end

def create
  
  #not checked this works
  csv = CSV.read(params[:file].path, headers: true)
  
  product_import_error_check(csv)  
  
end


def product_import_error_check(csv)

  product_import_errors = []
   
  headers = csv.headers
   
  #check no header values are nil
  if headers.length != headers.compact.length
       product_import_errors[0] = 'Compulsory columns are not correct, they are either missing, in the incorrect order or misspelt. Please correct erros and reload file.'   
  else
    #check fixed headers are correct
  check_array = ['Clause Ref','Subtitle','Product Ref','Product Name','Item Ref', 'Item Name']
    check_heaer_array = headers[0..5]   
    if check_array != check_header_array
       product_import_errors[0] = 'Compulsory columns are not correct, they are either missing, in the incorrect order or misspelt. Please correct erros and reload file.'
    else
      if clause.blank?
        @csv.each_with_index do |line, i| 
          #private method
          clause_check(line[0], line[1])
                 
          if check_clause.blank?      
            product_import_errors[i] = 'Clause reference' << line[0] << 'does not exist.' 
          end
        end
      end
    end
   
    if product_import_errors.empty?
      
    else
      redirect_to :action=>'new'      
    end
  end
end



def csv_product_import

  require 'tempfile' 
  require 'csv'
  
  @csv = CSV.read(params[:csv_file].tempfile.to_path.to_s, {:headers => true, }) 

  #validate csv to check that correct columns are included and they are completed

  @csv.each do |line| 
    
    #line[0] = clause reference
    #line[1] = clausetitle
    #line[2] = clause substitle
    #line[3] = product reference
    #line[4] = product name
    #line[5] = item reference
    #line[6] = item name


    #array of tx3)ids for headers
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
    
    #find or create product record
      #get clause_id for clause reference - clauseref and clause title
      #private method
      clause_check(line[0], line[1])
            
      #check txt4 record for clause substitle - find or create     
      subtitle_check = Txt4.find_or_create_by_text(line[2])
      #subtitle_check = Txt4.where(:text => line[2]).first_or_create
      
      #find or create product record
      
    #if not full overwrite  
      #if product already exists
      
      

      performance_id_array = [] 
       
      (7..line_array_length).each do |i|
                     
        txt6_check = Txt6.find_or_create_by_text(line[i])
        #txt6_check = Txt6.where(:text => line[i]).first_or_create        

        performance = Performances.includes(:txt3).where(txt3_id => header_txt3_id_array[i], txt6_id => txt6_check.id).first
        performance_id_array[i] = performance.id          
      end       
      performance_id_array.compact
       
      #check if variant exists
      product_check = Product.joins(:characteristics).where(:clause_id => clause_check.id, 'characteristics.performance_id' => performance_id_array).first
      if product_check
        #if exists update checked date  
      else    
        #if does not exist - create variant - record new
      end
    #if full overwrite
      #delete existing and start again? - depends on method of checking currency of products specified 
      #copy to archive
      #if new is same as old - delete archive    


    #import data for each variation of the product
    line_array_length = line.length
  
    (0..line_array_length).each do |i|      
    
      headers[i]
      line[i]
    
    end  
  end
end

def product_specline_update
  
  all_projects = Project.all
  
  all_projects.each do |project|
    clauses_ids = Clause.joints(:speclines).where('speclines.project_id = ?  AND speclines.linetype_id = ?', project.id, 5).collect{|i| i.id}
    
    clauses_ids.each do |clauses_id|
      #get relevant speclines for clause
      clause_ speclines = Specline.where(:project_id => project.id, :clause_id => clause.id, :linetype => 5) 
    
    
    end  
  end  
  
end


private

def find_current_performance_pairs(current_specline)

  performance_id_array = []
  txt3_array = []
  i = 0
  clause_speclines.each do |clause_specline|
    i = i + 1  
    
    txt6_string = clause_specline.txt6.text
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
        txt3_text_array(clause_specline.txt3_id, txt6_id)         
      end      
    else
      #search performance ids
      txt3_text_array(clause_specline.txt3_id, clause_specline.txt6_id)       
    end
  end
end


def txt3_text_array(txt3_id, txt6_id)
  performance = Performances.includes(:txt3).where(txt3_id => txt3_id, txt6_id => txt6_id).first
  performance_id_array[i] = performance.id        
  txt3_array[i] = performance.txt3.text
  txt3_array.compact  
end


def clause_check(clauseref, clausetitle)
  clause_check = Clause.joins(:clausetitle, :clauseref => [:subsection => [:section]]).where('section.ref = ? AND subsection.ref = ? AND clauseref.clausetype_id = ? AND clauseref.clause =? AND clauseref.subclause = ? AND clausetitle.text', clauseref[0], clauseref[1..2], clauseref[3], clauseref[4], clauseref[5..6], clausetitle).first  
end

    
end
