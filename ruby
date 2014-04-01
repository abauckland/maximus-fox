#PRODUCT IDENTITY DATA
#get all lines with product identity data in selected clause
specline = Specline.where(:id => params[:id]).first

#get identity pairs in clause which have been completed, not including current line
product_identity_pairs = Specline.joins(:identities => [:identvalues => [:identtexts]).where(
 :project_id => specline.project_id,
 :clause_id => specline.clause_id,
 :linetype_id => 10,
 ).where('identtexts.text != ?', 'not specified')
 ).where('id <> ?', params[:id]
 ).pluck(:identity_id)

#get possible products
possible_products_identity = Products.joins(:clauseproducts, :identities).where(
  identity.id HAVING product_identity_pairs,
  'clauseproducts.clause_id' => possible_clauses)



#PRODUCT PERFORMANCE DATA
#get all lines with product data in selected clause, not including current line
specline = Specline.where(:id => params[:id]).first
product_perform_pairs = Speclines.joins(:perfoms => [:performvaluearrays => [:performvalues => [:performtexts]]]).where(
 :project_id => specline.project_id, 
 :clause_id => specline.clause_id, 
 :linetype_id => 11
 ).where('performtexts.text != ?', 'not specified')
 ).where('id <> ?', params[:id]
 ).pluck(:perform_id)

#get array of perform pairs for each line
array_perform_pairs = []
product_perform_pairs.each_with_index do |perform_pair, i|
 value_pairs = Performvalues.joins(:performvaluearrays => [:performs]).where('performs.id' => perform_pair)
 
 #get array of pairs for each perform pair - can be more than one pair
 line_pairs = []
 value_pairs.each_with_index do |value_pair, n|
  single_perform_pair = Performs.joins(:performvaluearrays => [:performvalues]).where(:performkey_id => perform_pair.performkey_id, 'performvalues.id => value_pair.id).first
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





#for all products list all possible txt3 ids
perform_txt3_option_ids = Perform.joins(:products).where('products.id => possible_product_ids).collect{|x| x.txt3_id}.uniq

#delete from list txt3 ids in current clause
lines.each do |line|
 perform = Perform.where(:id => line.perform_id).first
 if perform_txt3_option_ids.include?(perform.txt3_id)
  perform_txt3_option_ids.delete(perform.txt3_id
 end
end

#form list of possible txt3 values to populate drop down list





#update perform record

#txtunit value = 'not selected' = 1
new_perform_pair = Perform.joins(:txt3, :txtunits).where('txt3s.text' => params[:value], 'txtunits.id' => 1).first

#get specline
specline.perform_id = new_perform_pair.id
specline.save
#save changes

send params[:value]



#new data line, or linetype changed to data
#perform_id = 1




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


#PRODUCT DATA LOAD

#create hash of identity pairs
#identity_pair_id_array
#create hash of perform pairs
#perform_pair_id_array

#check if product exists with same identity pairs
array_length = identity_pair_id_array.length

Product.joins(:descripts => :identities).
 where('identities.id => identity_pair_id_array)
 group(:id).
 having('count(*) = #{array_length}').
 first


#check if any products have matching, but not all, identity pairs
#get all products with at least two matches (single match would be manufacturer only)
Product.joins(:descripts => :identities).
 where('identities.id' => identity_pair_id_array)
 group(:id).
 having('count(*) > 1')

#check number of products returned
#if more than one product returned
#compare resuilts from query
#.count??


#check if product with same perform pairs exist
array_length = perform_pair_id_array.length

Product.joins(:instances => [:charcs => [:performs]]).
 where('performs.id' => perform_pair_id_array)
 group(:id).
 having('count(*) = #{array_length}').
 first


#save data
#if new product
 new_product = Product.create(:producttype_id => ??)
 new_product_clause = Clauseproducts.create(:product_id => new_product, :clause)

#if update existing or new product
 new_identity_pairs.each do |pair|
  new_product_ident = Descripts.find_or_create(:product_id => new_product.id, :identity_id => pair.id)
 end


#if new instance of new product
 instance = Instance.create(:product_id => new_product.id)

#if new instance of existing product
 instance = Instance.create(:product_id => existing_product.id)

#if existing instance
# may be many instance how know which one????
 instance = Instance.where(:product_id => product.id


#if update existing or new instance
 new_perform_pairs.each do |pair|
  new_product_ident = Charcs.find_or_create(:instance_id => instance.id, :perform_id => pair.id)
 end




#PRODUCT DATA BACK OUT









