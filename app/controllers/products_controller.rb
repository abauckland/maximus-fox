class ProductsController < ApplicationController

before_filter :require_user, :except => [:product_key, :product_value]


layout "products"

def index
  current_user = User.first
  
  @product_array = []

    #get unique performance pairs for selected range of clauses
    product_ids = Product.joins(:descripts => [:identity => [:identvalue]]).where('identvalues.company_id' => 35).collect{|x| x.id}.uniq

    if product_ids.empty?
      redirect_to new_productimport_path
    else

    #all identkeys for manufacturer
    ident_header_array = Identkey.joins(:identities => :descripts).where('descripts.product_id' => product_ids).pluck(:text)
    #all performkeys for manufacturer
    perform_header_array = Performkey.joins(:performs => [:charcs => [:instance]]).where('instances.product_id' => product_ids).pluck(:text)

    
    @headers_row = []
    #set up haeders
    @headers_row[0] = "clauseref"
    @headers_row[1] = "clausetitle"
    @headers_row[2] = "producttype"

    ident_header_array.each_with_index do |ident, i|
      @n = (3 + i)
      @headers_row[@n] = ident_header_array
    end

    @n = (@n + 1)
    @headers_row[@n] = "instance"


    perform_header_start = @n
    perform_header_array.each_with_index do |perform, i|
      @m = @n + i
      @headers_row[@m] = perform_header_array
    end
    perform_header_end = @m

    perform_header_range = (@n..@m)

    #add header row to csv


    #get units for headers
    @unit_row =[]

    perform_header_array.each_with_index do |key, i|
          
      unit = Unit.joins(:valuetypes => [:performvalues => [:performs => [:performkey, :charcs => :instance]]]).where('performkeys.text' => key, 'instances.product_id' => product_ids).first
      if unit
        @unit_row[perform_header_start + i] = unit.text
      end
    end

    #add units row to csv

 
 
    #get standards for headers
    @standard_row =[]

    perform_header_array.each_with_index do |key, i|
      standard = Standard.joins(:valuetypes => [:performvalues => [:performs => [:performkey, :charcs => :instance]]]).where('performkeys.text' => key, 'instances.product_id' => product_ids).first
      if standard
        @standard_row[perform_header_start + i] = standard.ref
      end
    end

    #add standards row to csv
    


    #get all products
    instances = Instance.where(:product_id => product_ids)
    
    instances.each_with_index do |instance, i|

      #check if instance applies to more than one clauseref
      instance_clauses = Clause.joins(:clauseproducts => [:product => :instances]).where('instances.id' => instance.id)

      instance_clauses.each do |instance_clause|
  
  product = {}
        
        clause = Clause.where(:id => instance_clause.id).first
        product[0] = clause.clause_code
        product[1] = clause.clausetitle.text

       
        producttype = Producttype.joins(:products => :instances).where('instances.id' => instance.id).pluck(:text)
        product[2] = producttype


        n = 3
        ident_header_array.each do |identkey|
          n = n + 1
          ident_value = Identvalue.joins(:identities => [:identkey, :descripts => [:product => :instances]]).where('instances.id' => instance.id, 'identkeys.text' => identkey).first
   
          if ident_value
            if ident_value.identtxt_id
              product[n] = ident_value.identtxt.text
            else
              product[n] = ident_value.company.company_name
            end
          else
            product[n] =  ""
          end
        end

        n = n + 1
        product[n] = instance.id

        n = n + 1
        perform_header_array.each do |performkey|
          n = n + 1
          perform_text = Performtxt.joins(:performvalues => [:performs => [:performkey, :charcs]]).where('charcs.instance_id' => instance.id, 'performkeys.text' => performkey).first
          if perform_text
            product[n] = perform_text.text
          else
            product[n] = ""
          end
        end
      end
    end
    
    #add product data row to csv
    @product_array.push(product)
    end
  end

def new
  
end

def create
  
end


def product_specline_update
            
##get clause in project with speclines that have data        
##get relevant speclines for clause
##is line before a subtitle?  
##find next substitle or end of product attributes
##check linetype of intermediate lines     
##check all attributes (linetypes 5 & 6) 
##check only linietype 5 attributes
##for product speclines get performance pairs
##test is product exists
##if product does not exist
##find attributes that are not correct
#end to each clause of project
#end to each project    
   
end



private

end
