class ProductexportsController < ApplicationController

before_filter :require_user

layout "products"


def index

  #list of all relevant clauses that can be selected for download
  @product_clauses = Clause.joins(:clauseproducts => [:product => [:descripts => [:identity => [:identvalue]]]]).where('identvalues.company_id' => current_user.company_id)

  
end


def export
  
  CSV.generate do |csv|
  
    #get unique performance pairs for selected range of clauses
    product_ids = Product.joins(:descripts => [:identity => [:identvalue]]).where('identvalues.company_id' => company_id).pluck(:id)

    #all identkeys for manufacturer
    ident_header_array = Identkey.joins(:identities => :descripts).where('descripts.products_id' => products_ids).pluck(:text)
    #all performkeys for manufacturer
    perform_header_array = Performkey.joins(:charcs => :instance).where('instances.product_id' => product_ids).pluck(:text)

    #set up haeders
    headers_row[0] = "clauseref"
    headers_row[1] = "clausetitle"
    headers_row[2] = "producttype"

    ident_header_array.each_with_index do |ident, i|
      n = 2 + i
      headers_row[n] = ident_header_array
    end

    n = n + 1
    headers_row[n] = "instance"


    perform_header_start = n
    perform_header_array.each_with_index do |perform, i|
      m = n + i
      headers_row[m] = perform_header_array
    end
    perform_header_end = m

    perform_header_range = (n..m)

    #add header row to csv
    csv << headers_row


    #get units for headers
    unit_row =[]

    perform_header_array.each_with_index do |key, i|
      unit = Unit.where('performkeys.text' => key, 'identvalues.company_id' => company_id).first
      if unit
        unit_row[perform_header_start + i] = unit.text
      end
    end

    #add units row to csv
    csv << unit_row
 
 
    #get standards for headers
    standard_row =[]

    perform_header_array.each_with_index do |key, i|
      standard = Standard.where('performkeys.text' => key, 'identvalues.company_id' => company_id).first
      if standard
        standard_row[perform_header_start + i] = standard.text
      end
    end

    #add standards row to csv
    csv << standard_row


    #get all products
    instances = Instance.where(:product_id => product_ids)
    
    instances.each_with_index do |instance, i|

      #check if instance applies to more than one clauseref
      instance_clauses = Clauses.where('instances.id' => instance.id)

      instance_clauses.each do |instance_clause|
  

        row = []

        clause = Clause.where(:id => instance_clause.id).first
        row[0] = clause.clause_code
        row[1] = clause.clausetitle.text

        producttype = Producttype.where('instances.id' => instance.id).pluck(:text)
        row[2] = producttype.text


        n = 3
        ident_header_array.each do |identkey|
          n = n + 1
          ident_value = Identvalue.where('instances.id' => instance.id, 'identkeys.text' => identkey).first
   
          if ident_value
            if ident_value.identtxt_id
              row[n] = ident_value.identtxt.text
            else
              row[n] = ident_value.company.name
            end
          else
            row[n] = ""
          end
        end

        n = n + 1
        row[n] = instance.id

        n = n + 1
        perform_header_array.each do |performkey|
          n = n + 1
          perform_text = Performtxt.where('instances.id' => instance.id, 'performkeys.text' => performkey).first
          if perform_text
            row[n] = perform_text.text
          else
            row[n] = ""
          end
        end
      end
    end
    
    #add product data row to csv
    csv << row
  
    end
  end

    
end
