class ProductsController < ApplicationController

before_filter :require_user, :except => [:product_keys, :product_values]


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
    ident_header_array = Identkey.joins(:identities => :descripts).where('descripts.product_id' => product_ids).collect{|x| x.text}.uniq
    #all performkeys for manufacturer
    perform_header_array = Performkey.joins(:performs => [:charcs => [:instance]]).where('instances.product_id' => product_ids).collect{|x| x.text}.uniq

    
    @headers_row = []
    #set up haeders
    @headers_row[0] = "clause ref"
    @headers_row[1] = "clause title"
    @headers_row[2] = "product type"

    ident_header_array.each_with_index do |ident_text, i|
      @n = (3 + i)
      @headers_row[@n] = ident_text
    end

    @n = (@n + 1)
    @headers_row[@n] = "instance"

    @n = (@n + 1)
    perform_header_start = @n
    perform_header_array.each_with_index do |perform_text, i|
 
      header_title_string = perform_text.to_s 
     
      #get units for headers
      unit = Unit.joins(:valuetypes => [:performvalues => [:performs => [:performkey, :charcs => :instance]]]).where('performkeys.text' => perform_text, 'instances.product_id' => product_ids).first
      if unit
        header_title_string = header_title_string + ' (' + unit.text.to_s + ') '
      end 

      #get standards for headers
      standard = Standard.joins(:valuetypes => [:performvalues => [:performs => [:performkey, :charcs => :instance]]]).where('performkeys.text' => perform_text, 'instances.product_id' => product_ids).first
      if standard
        header_title_string = header_title_string + ' (' + standard.ref.to_s + ') '
      end
    
      @m = @n + i
      @headers_row[@m] = header_title_string
    end
    perform_header_end = @m

    perform_header_range = (@n..@m)
    #add header row to csv
    


    
    
    #get all clause for products    
  #  product_clauses = Clauseproduct.where(:product_id => product_ids).collect
    
  #  product_clauses.each do |product_clause|
          
      product_clause_instances = Instance.joins(:product => :clauseproducts).where('clauseproducts.product_id'=> product_ids)
    
      product_clause_instances.each_with_index do |instance, i|

      #check if instance applies to more than one clauseref
  
  product = []
        
        clause = Clause.joins(:clauseproducts => [:product => :instances]).where('instances.id' => instance.id).first
        product[0] = clause.clause_code
        product[1] = clause.clausetitle.text

       
        producttype = Producttype.joins(:products).where('products.id' => instance.product_id).first
        product[2] = producttype.text


        n = 2
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
        product[n] = instance.code

        n = n
        perform_header_array.each do |performkey|
          n = n + 1
          perform_text = Performtxt.joins(:performvalues => [:performs => [:performkey, :charcs]]).where('charcs.instance_id' => instance.id, 'performkeys.text' => performkey).first
          if perform_text
            product[n] = perform_text.text
          else
            product[n] = ""
          end
        end
                  #add product data row to csv
    @product_array.push(product)
      end

#    end
    


    end
  end

def new
  
end

def create
  
end



 def product_keys
    #get possible keys for product clause
    #get selected specline
    specline = Specline.where(:id => params[:id]).first
    
    #get eligble clause references for products
    get_sub_clause_ids(specline.clause_id)
    
    #get product identity pairs in clause which have been completed, not including current line
    product_identity_pairs = Specline.joins(:clause, :identity => [:identvalue => :identtxt]).where(
      :project_id => specline.project_id,
      'clauses.clauseref_id' => @sub_clause_ids, 
      :linetype_id => 10
      ).where('identtxts.text != ?', "Not specified"
      ).where('speclines.id <> ?', specline.id
      ).pluck('speclines.identity_id')
   
    #get product perform pairs in clause which have been completed, not including current line
    product_perform_pairs = Specline.joins(:clause, :perform => [:performvalue => [:performtxt]]).where(
      :project_id => specline.project_id, 
      'clauses.clauseref_id' => @sub_clause_ids, 
      :linetype_id => 11
      ).where('performtxts.text != ?', "Not specified"
      ).where('speclines.id <> ?', specline.id
      ).pluck('speclines.perform_id')

    #get possible products for identity and perform pairs
    if product_identity_pairs.empty?
      if product_perform_pairs.empty?
         possible_products = Product.joins(:clauseproducts).where(
          'clauseproducts.clause_id' => @sub_clause_ids)  
      else
        possible_products = Product.joins(:clauseproducts, :instances => :charcs).where(
          'clauseproducts.clause_id' => @sub_clause_ids,
          'charcs.perform_id'=>  product_perform_pairs)        
      end
    else
      if product_perform_pairs.empty?
        possible_products = Product.joins(:clauseproducts, :descripts).where(
          'clauseproducts.clause_id' => @sub_clause_ids,
          'descripts.identity_id'=> product_identity_pairs) 
      else
        possible_products = Product.joins(:clauseproducts, :descripts, :instances => :charcs).where(
          'clauseproducts.clause_id' => @sub_clause_ids,
          'descripts.identity_id'=> product_identity_pairs,
          'charcs.perform_id'=> product_perform_pairs)     
      end        
    end
    possible_product_ids = possible_products.collect{|x| x.id}.uniq  

   
    #get all possible identity keys
    identity_option_texts = Identkey.joins(:identities => [:descripts => :product]).where(
      'products.id' => possible_product_ids
      ).collect{|x| x.text}.uniq
    #get all existing identity keys within selected clause    
    existing_identity_keys = Identkey.joins(:identities => :speclines).where(
      'speclines.project_id' => specline.project_id,
      'speclines.clause_id' => specline.clause_id,
      'speclines.linetype_id' => 10
      ).where('speclines.id <> ?', params[:id]
      ).pluck('identkeys.text')
    #get list of identity keys not in use within selected clause
    identity_key_options = identity_option_texts - existing_identity_keys


    #get all possible perform keys
    performkey_option_texts = Performkey.joins(:performs => [:charcs => [:instance => :product]]).where(
      'products.id' => possible_product_ids
      ).collect{|x| x.text}.uniq
    #get all existing perform keys within selected clause 
    existing_perform_keys = Performkey.joins(:performs => :speclines).where(
      'speclines.project_id' => specline.project_id,
      'speclines.clause_id' => specline.clause_id,
      'speclines.linetype_id' => 11
      ).where('speclines.id <> ?', params[:id]
      ).pluck('performkeys.text')  
    #get list of perform keys not in use within selected clause
    perform_key_options = performkey_option_texts - existing_perform_keys
   

    #get list of all identity and perform keys not in use within selected clause
    product_key_options = identity_key_options + perform_key_options

    #assign keys to hash for select drop down
    @product_key_options = {}
    product_key_options.each do |key|    
      @product_key_options[key] = key  
    end
    @product_key_options['Not specified'] = 'Not specified'

    render :json => @product_key_options       
 end


 def product_values

    specline = Specline.where(:id => params[:id]).first
    
    #get eligble clause references for products
    get_sub_clause_ids(specline.clause_id)
    
    #get product identity pairs in clause which have been completed, not including current line
    product_identity_pairs = Specline.joins(:identity => [:identvalue => :identtxt]).where(
      :project_id => specline.project_id,
      :clause_id => specline.clause_id, 
      :linetype_id => 10
      ).where('identtxts.text != ?', "Not specified"
      ).where('speclines.id <> ?', specline.id
      ).pluck('speclines.identity_id')
   
    #get product perform pairs in clause which have been completed, not including current line
    product_perform_pairs = Specline.joins(:perform => [:performvalue => [:performtxt]]).where(
      :project_id => specline.project_id,
      :clause_id => specline.clause_id, 
      :linetype_id => 11
      ).where('performtxts.text != ?', "Not specified"
      ).where('speclines.id <> ?', specline.id
      ).pluck('speclines.perform_id')

    @product_value_options = {}
    #get cpossible products for line
    #if specline linetype == 10 (identity pair)
    #get possible products for identity and perform pairs
    if product_identity_pairs.empty?
      if product_perform_pairs.empty?
         possible_products = Product.joins(:clauseproducts).where(
          'clauseproducts.clause_id' => @sub_clause_ids)  
      else
        possible_products = Product.joins(:clauseproducts, :instances => :charcs).where(
          'clauseproducts.clause_id' => @sub_clause_ids,
          'charcs.perform_id'=>  product_perform_pairs)        
      end
    else
      if product_perform_pairs.empty?
        possible_products = Product.joins(:clauseproducts, :descripts).where(
          'clauseproducts.clause_id' => @sub_clause_ids,
          'descripts.identity_id'=> product_identity_pairs) 
      else
        possible_products = Product.joins(:clauseproducts, :descripts, :instances => :charcs).where(
          'clauseproducts.clause_id' => @sub_clause_ids,
          'descripts.identity_id'=> product_identity_pairs,
          'charcs.perform_id'=> product_perform_pairs)     
      end        
    end
    possible_product_ids = possible_products.collect{|x| x.id}.uniq


    if specline.linetype_id == 10
      key_id = specline.identity.identkey_id 
      if specline.identity.identkey.text == "Manufacturer"
        identity_option_values = Company.joins(:identvalues => [:identities => :descripts]).where(
          'descripts.product_id' => possible_product_ids,
          'identities.identkey_id' => key_id
          )
      else
        identity_option_values = Identtxt.joins(:identvalues => [:identities => [:descripts, :identkey]]).where(
          'descripts.product_id' => possible_product_ids,
          'identities.identkey_id' => key_id
          )  
      end
      identity_option_values.each do |value|    
        @product_value_options[value.id] = value.text 
      end
      #find identity value pair of key and 'Not specified' value
      performvalue_not_specified_option = Identtxt.where(:text => "Not Specified").first          
      @product_value_options[performvalue_not_specified_option.id] = performvalue_not_specified_option.text 
      
      
    else
      key_id = specline.perform.performkey_id
      performvalue_option_values = Performvalue.joins(:performs => [:charcs => [:instance => [:product => [:clauseproducts, :descripts]]]]).where(
        'descripts.product_id' => possible_product_ids,
        'performs.performkey_id' => key_id
        )
    
      performvalue_option_values.each do |value| 
        
        #value.full_perform_value does not work in here for some reason - results in multipe units added to value
        if value.valuetype_id == nil
          new_value = ''     
        else
          if value.valuetype.unit_id == nil
            if value.valuetype.standard_id == nil
              new_value = '' 
            else  
              new_value = ' to ' << value.valuetype.standard.ref
            end     
          else        
            if value.valuetype.standard_id == nil
              new_value = value.valuetype.unit.text
            else
              new_value = value.valuetype.unit.text << ' to ' << value.valuetype.standard.ref   
            end   
          end                
        end
        @product_value_options[value.id] = value.performtxt.text + new_value
      end
      #find perform value pair of key and 'Not specified' value
      performvalue_not_specified_option = Performvalue.where(:performtxt_id => 1).first          
      @product_value_options[performvalue_not_specified_option.id] = performvalue_not_specified_option.performtxt.text                      
    end  


    render :json => @product_value_options  
 end




private
def get_sub_clause_ids(clause_id)

  clause = Clause.where(:id => clause_id).first
  if clause.clauseref.subclause != 0
    @sub_clause_ids = [clause.id]
  else
    if clause.clauseref.clause != 0 
      if clause.clauseref.clause.multiple_of?(10)
        low_ref = clause.clauseref.clause
        high_ref = clause.clauseref.clause + 9
        @sub_clause_ids = Clause.joins(:clauseref).where('clauserefs.clausetype_id' => clause.clauseref.clausetype_id, 'clauserefs.clause' => [low_ref..high_ref]).pluck('clauses.id')
      else
        @sub_clause_ids = Clause.joins(:clauseref).where('clauserefs.clausetype_id' => clause.clauseref.clausetype_id, 'clauserefs.clause' => clause.clauseref.clause).pluck('clauses.id')
      end
    else
      @sub_clause_ids = Clause.joins(:clauseref).where('clauserefs.clausetype_id' => clause.clauseref.clausetype_id).pluck('clauses.id')
    end
  end
end

#end of class
end
