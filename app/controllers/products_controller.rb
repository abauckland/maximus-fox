class ProductsController < ApplicationController

before_filter :require_user


layout "products"

def index
  current_user = User.first
  
 # @txt3_id_array = Txt3.joins(:performances => [:characteristics => [:product => [:productgroup]]]).where('productgroups.supplier_id' => 1).order('text')
  @products = Product.all
 # @products = Product.includes(:productgroup =>[:txt4, :supplier, :clauses => [:clausetitle]]).where('productgroups.supplier_id' => 1).order('productgroups.clause_id', 'productgroup_id')

end

def new
  @product = Product.new
  @product_import_errors =params[:product_import_errors] 
end


def show

end


def product_specline_update
   
  Project.all.each do |project|
            
  ##get clause in project with speclines that have data      
    clauses_ids = Clause.joints(:speclines).where('speclines.project_id = ? AND speclines.linetype_id = ?', project.id, 5).collect{|i| i.id}

    
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

#get tx3 options for given performance value pair
def txt3_text_array(txt3_id, txt6_id) 
  txt3_array = Txt3.joins(:txt3units => :performance).where(:id => txt3_id, 'perforamnces.txt6_id' => txt6_id).collect{|i| i.text}.uniq.sort
end


#for given txt3 return txt6 options
def txt6_options(txt3_id)
  txt6_array = Txt6.joins(:performance => [:txt3unit => :txt3]).where('txt3.id' => txt3_id).collect{|i| i.text}.uniq.sort  
end

#for given txt3 return txt6 options with units as an array
def txt6_units_options(txt3_id)
  txt6_units_array = Txt6.joins(:performance => [:txt3unit => :unit]).where('txt3units.txt3_id' => txt3_id).collect{|i| [i.text, i.performance.txt3units.units.text]}.uniq.sort 
#display each line as txt6_units_array[i][0] << ' ' << txt6_units_array[i][1] 
end

#for given txt3 return txt6 options with BS reference as an array
def txt6_units_options(txt3_id)
  txt6_bs_array = Txt6.joins(:performance => [:standardperformance => :standard]).where('txt3units.txt3_id' => txt3_id).collect{|i| [i.text, i.standardperformance.standard.ref, i.standardperformance.standard.part]}.uniq.sort 
#display each line as txt6_bs_array[i][0] << ' to ' << txt6_bs_array[i][1] << '-' << txt6_bs_array[i][2]  
end

#for given txt3 return txt6 with combined bs and units
def txt6_units_options(txt3_id)
  txt6_bs_array = Txt6.joins(:performance => [:standardperformance => :standard, :txt3unit => :unit]).where('txt3units.txt3_id' => txt3_id).collect{|i| [i.text, i.performance.txt3units.units.text, i.standardperformance.standard.ref, i.standardperformance.standard.part]}.uniq.sort 
#display each line as txt6_bs_array[i][0] << ' ' << txt6_units_array[i][1] << 'to ' << txt6_bs_array[i][2] << '-' << txt6_bs_array[i][3]  
end


def clause_check(clauseref, clausetitle)
  clause_check = Clause.joins(:clausetitle, :clauseref => [:subsection => [:section]]).where('section.ref = ? AND subsection.ref = ? AND clauseref.clausetype_id = ? AND clauseref.clause =? AND clauseref.subclause = ? AND clausetitle.text', clauseref[0], clauseref[1..2], clauseref[3], clauseref[4], clauseref[5..6], clausetitle).first  
end



def product_performance_pairs

#check if substitle
  #if no substitle then get all product data lines
    #check if all ok together
    #if not find nearest product match & change pairs not included
      #product_speclines = Specline.where(:project_id => , :clause_id => , :linetype =>  )
      #perform_array = []
      #product_speclines.each_with_index do |specline, i|
        #specline.txt3        
        #specline.txt6unit - check for an array of values
        #
        #
        #perform_array[i] = 
      #end
      
      #get all possible products for each pair
      
      #product_ids = Characteristic.where(:performance_id => perform_array).collect{|i| i.product_id}
      
      #find product with most matches - merge array and get mode
      
      #performance_pairs.each do |pair|
        #check_performance_exists = Characteristic.where(:performance_id => pair.id, :product_id => mode_product_id)
        #if check_performance_exists.blank?
          #change specline linetype
        #end
      #end

#if subtitles
  #find if any product speclines above substitles
  #product_subtitles = Specline.where(:project_id => , :clause_id => , :linetype => 10)
  #product_subtitle_locations = product_subtitles.collect{|i| i.clauseline}.sort

  #check for product groups between subtitles
  #if product_subtitle_locations.length == 1
    #= Specline.where(:project_id => , :clause_id => , :linetype => 11, :clauseline > product_subtitle_locations.first)

  #else
    #array_product_pairs = []
    
    #check_product_speclines_above_first_subtitle
    #= Specline.where(:project_id => , :clause_id => , :linetype => 11, :clauseline < product_subtitle_locations.first)

    #product_subtitle_locations.each_with_index do |subtitle, i|
    #if product_subtitle_locations.length > i      
      #= Specline.where(:project_id => , :clause_id => , :linetype => 11, :clauseline > (subtitle[i]..subtitle[i+1])        
    #if product_subtitle_locations.length > i      
      #= Specline.where(:project_id => , :clause_id => , :linetype => 11, :clauseline > (subtitle[i]..subtitle[i+1])
    #if product_subtitle_locations.length > i  
      #= Specline.where(:project_id => , :clause_id => , :linetype => 11, :clauseline > subtitle)
    #end
  #end
end

def check_txt6unit_array
  #always store txt6unit value as an array
  #txt6 = array
end

    
end
