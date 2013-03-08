class ProductexportsController < ApplicationController

before_filter :require_user

layout "suppliers"


def index

  #list of all relevant clauses that can be selected for download
  @product_clauses = Clause.joins(:productgroup).where('productgroup.company_id' => current_user.company_id)

  
end


def export
  
  CSV.generate do |csv|
  
    #get unique performance pairs for selected range of clauses
    clause_id_array = Clause.where(:id => params[:clause_ids]).collect{|i| i.id}.uniq.sort
    selected_products = Product.joins().where(:company_id => current_user.company_id, :clause_ids => clause_id_array)
  
  
    #get unique txt3 values for column names + fixed column names
    product_attributes = Txt3.joins(:performances => [:characteristics => [:product => [:productgroup]]]).where('productgroups.company_id' => current_user.company_id, 'productgroups.clauses_id' => clause_id_array).collect{|i| i.text}.uniq.sort
  
    fixed_attributes = ['clause Ref', 'Substitle']
    attribute_arry = fixed_attributes << product_attributes
  
    #add column headers to CSV
    csv << attribute_arry
  
    ##for each relevant product
    selected_products.each do |product|
  
      #get fixed attribute data
      clauseref = product.productgroup.clause.clause_code
      subtitle = product.productgroup.txt4.text

      product_data << clause_ref
      product_data << subtitle
    
      #get performance characteristics for each product  
      product_attributes.each do |attribute|
        attribute_value = Txt6.where('characteristics.product_id' => product.id, 'txt3.text' => attribute).first
        if attribute_value
          csv << attribute_value
        else
          csv << nil
        end
      end    
    end
  end
end

    
end
