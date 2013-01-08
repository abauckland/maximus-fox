class ProductsController < ActionController::Base

layout "supplier"

def index
   @abouts = About.all
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

    #array of tx3)ids for headers
    line_array_length = line.length
      
      header_txt3_id_array = []        
      (5..line_array_length).each do |i|        

        header_txt3_check = Txt4.where(:test => headers[i]).first
        if header_txt3_check.blank?
          header_txt3_check = Txt4.create(:test => headers[i]).first               
        end
        header_txt3_id_array[i] = header_txt3_check.id
        #starts from 5...
      end







    
    #find or create product record
      #get clause_id for clause reference - clauseref and clause title
      clauseref = line[0]
      clausetitle = line[1]
      clause_check = Clause.joins(:clausetitle, :clauseref => [:subsection => [:section]]).where('section.ref = ? AND subsection.ref = ? AND clauseref.clausetype_id = ? AND clauseref.clause =? AND clauseref.subclause = ? AND clausetitle.text', clauseref[0], clauseref[1..2], clauseref[3], clauseref[4], clauseref[5..6], clausetitle).first
      
        #if not valid
          #stop import or 
          #do not import row and record row not added.
      
      #check txt4 record for clause substitle - find or create
      clause_subtitle = line[2]
      subtitle_check = Txt4.where(:test => clause_subtitle).first
      if subtitle_check.blank?
        subtitle_check = Txt4.create(:test => clause_subtitle).first               
      end
      
      #find or create product record
      
    #if not full overwrite  
      #if product already exists
      
      

      performance_id_array = [] 
       
      (5..line_array_length).each do |i|
                     
        txt6_check = Txt6.where(:test => line[i]).first
        if txt6_check.blank?
          txt6_check = Txt6.create(:test => line[i]).first               
        end
        txt6_id = txt6_check.id
        
        performance = Performances.includes(:txt3).where(txt3_id => header_txt3_id_array[i], txt6_id => txt6_id ).first
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

private

def find_current_performance_pairs(current_specline)
  ####!!!!!!!!!! i + n does not work 

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
        performance = Performances.includes(:txt3).where(txt3_id => clause_specline.txt3_id, txt6_id => txt6_id).first
        performance_id_array[i] = performance.id        
        txt3_array[i] = performance.txt3.text
        txt3_array.compact        
      end      
    else
      #search performance ids
      performance = Performances.includes(:txt3).where(txt3_id => clause_specline.txt3_id, txt6_id => clause_specline.txt6_id).first
      performance_id_array[i] = performance.id        
      txt3_array[i] = performance.txt3.text
      txt3_array.compact        
    end
  end
end
    
end
