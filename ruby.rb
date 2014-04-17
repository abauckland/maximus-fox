#UPLOAD TEST

#check for multiple values/strings split with comma




#PRODUCT IDENTITY DATA
#get all lines with product identity data in selected clause
specline = Specline.where(:id => params[:id]).first

#get identity pairs in clause which have been completed, not including current line
product_identity_pairs = Specline.joins(:identities => [:identvalues => [:identtxts]).where(
 :project_id => specline.project_id,
 :clause_id => specline.clause_id,
 :linetype_id => 10,
 ).where('identtxts.text != ?', 'not specified')
 ).where('id <> ?', params[:id]
 ).pluck(:identity_id)

#get possible products
possible_products_identity = Products.joins(:clauseproducts, :descripts => :identities).where(
  identity_id => 
  'clauseproducts.clause_id' => possible_clauses)



#PRODUCT PERFORMANCE DATA
#get all lines with product data in selected clause, not including current line
specline = Specline.where(:id => params[:id]).first
product_perform_pairs = Speclines.joins(:performs => [:performvalues => [:performtxts]]).where(
 :project_id => specline.project_id, 
 :clause_id => specline.clause_id, 
 :linetype_id => 11
 ).where('performtxts.text != ?', 'not specified')
 ).where('id <> ?', params[:id]
 ).pluck(:perform_id)

#get array of perform pairs for each line
array_perform_pairs = []
product_perform_pairs.each_with_index do |perform_pair, i|
 value_pairs = Performvalues.joins(:performs).where('performs.id' => perform_pair)
 
 #get array of pairs for each perform pair - can be more than one pair
 line_pairs = []
 value_pairs.each_with_index do |value_pair, n|
  single_perform_pair = Performs.where(:performkey_id => perform_pair.performkey_id, :performvalue_id => value_pair.id).first
  line_pairs[n-1] = single_perform_pair.id
 end

 #get all possible combinations of perform pairs
 if i = 1
  array_perform_pairs = line_pairs
 else
  array_perform_pairs = array_perform_pairs.product(line_pairs)
 end

end


#FIND LIST OF PRODUCTS
if array_perform_pairs
#for each array of perform pairs, seach for products
product_id_array = []
array_perform_pairs.each_with_index do |perform_pairs, i|
 possible_product_ids = Products.joins(:clauseproducts, :instances => [:performs]).where('performs.id HAVING perform_pairs, 'clauseproducts.clause_id' => possible_clause_ids).pluck(:id)
 
 #return list of products common to all sets of perform pairs
 if i = 1
  product_id_array = possible_product_ids
 else
  product_id_array = possible_product_ids & product_id_array
 end

end
end

#combine products with identity and perform
if possible_products_identity
 possible_products_ids = possible_products_identity & product_id_array
else
 if product_id_array
  possible_products_ids = product_id_array
 else
  ¿????????
 end
end





#for all products list all possible performkeys
performkey_option_texts = Performkey.joins(:performs => [:charcs => [:instances => :products]]).where('products.id => possible_product_ids).collect{|x| x.text}.uniq

#delete from list txt3 ids in current clause
existing_perform_keys = []
product_perform_pair_ids.each_with_index do |pair_id, i|
 key = Performkey.joins(:perform).where('performs.id' => pair_id).first
 existing_perform_keys[i] = key.text

end

#form list of possible perform keys values to populate drop down list
perform_key_options = performkey_option_texts - existing_perform_keys


#update key
#find perform pair for key where value = 'not selected'
#check if perform of identity pair
#could ply to both - how to check??
#if identkey.where(:text => params[]).first
#save to specline

#update value
#find key for line
#find perform pair for key and value
#save to specline



#update perform record

#txtunit value = 'not selected' = 1
new_perform_pair = Perform.joins(:performvalues => :performtxts).where('performtxts.text' => params[:value]).first

#get specline
specline.perform_id = new_perform_pair.id
specline.save
#save changes

send params[:value]



#new data line, or linetype changed to data
#blank or copy of existing
#keep same linetype as original
#perform_id = 1 or identity_id = 1

#delete data line

#change linteype from data line

#change linetype to data line
#completely blank? not selected, not selected

#move data line
#disable


#reinstate
#check if reinstatememt is valid option - if not do not do and prompt


#on linetype change check if product data is available
#get clause id for line
#check if product with clause exists

check_products = Product.joins(:clauses).where('clauses.id' => specline.clause_id).first
if check_products
 linetypes = Linetypes.where(:clausetype_id => specline.clause.clauseref.clausetype))
else
end


#how to filter products by clause reference hierarchy

#product has clause reference

#find products with finer clause reference _ progress on digit up tree each time
#find products with same reference
#find products down tree one digit at a time
#find all products below in tree

#F10.000 find all products below
#where subsection = F10

#F10.1000
#where subsection =F10, clausetype = 1

#F10.1100
#where subsection =F10, clausetype = 1, clause > [10..19]

#F10.1110
#where subsection =F10, clausetype = 1, clause = 11

#F10.1111
#where subsection =F10, clausetype = 1, clause = 11, subclause = 1


#find clauserefs equal or below
#determine number of zeros?
#where self = clauseref

def get_sub_clauserefs(clauseref)

if subclause != 0
 sub_clauseref = clauseref
else
 if clause != 0 
  if clause.multiple_of?(10)
    low_ref = clauseref.clause
    high_ref = clauseref.clause + 9
    sub_clauseref_ids = Clauseref.where(:clausetype_id => clauseref.clausetype_id, :clause => [low_ref..high_ref]).pluck(:id)
  else
    sub_clauseref_ids = Clauseref.where(:clausetype_id => clauseref.clausetype_id, :clause => clauseref.clause).pluck(:id)
  end
 else
    sub_clauseref_ids = Clauseref.where(:clausetype_id => clauseref.clausetype_id).pluck(:id)
 end
end


