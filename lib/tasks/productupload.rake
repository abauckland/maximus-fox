#bundle exec rake productupload:update
#*** cd/datat/myapp/current && /lib/tasks productupload RAILS_ENV = product

namespace :productupload do

 desc "upload and update product data"
 task :update => [:csv_product_upload, :product_specline_update] do 
 end 
 
  desc "import uploaded products"
  task :csv_product_upload  => :environment do
		 
    #stuff to do here
 		 
  end

  desc "update specline product data"
  task :product_specline_update  => :environment do
     
    #stuff to do here
     
  end  

end