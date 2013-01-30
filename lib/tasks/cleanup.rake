#bundle exec rake cleanup:remove_unused_records
#*** cd/datat/myapp/current && /lib/tasks cleanup RAILS_ENV = product

namespace :cleanup do

 desc "remove unused records from database"
 task :remove_unused_records => [:txt3_clean, :txt4_clean, :txt5_clean, :session_clean] do 
 end 
 
 desc "remove unused txt3 text"
 task :txt3_clean  => :environment do
		 
	#next section does not work, fail on finding Specline
    speclines = Specline.all.collect{|i| i.txt3_id}.uniq
    changes = Change.all.collect{|i| i.txt3_id}.uniq
    txt3_id_array = Txt3.all.collect{|i| i.id}
        
    unused_txt3_id_array = txt3_id_array - changes - speclines

    unused_txt3 = Txt3.where(:id => unused_txt3_id_array)
		 
    unused_txt3.each do |text|
      text.destroy
    end	 
		 
  end
  
   desc "remove unused txt4 text"
   task :txt4_clean  => :environment do
     
  #next section does not work, fail on finding Specline
    speclines = Specline.all.collect{|i| i.txt4_id}.uniq
    changes = Change.all.collect{|i| i.txt4_id}.uniq
    txt4_id_array = Txt4.all.collect{|i| i.id}
        
    unused_txt4_id_array = txt4_id_array - changes - speclines

    unused_txt4 = Txt4.where(:id => unused_txt4_id_array)
     
    unused_txt4.each do |text|
      text.destroy
    end  
     
  end
  
   desc "remove unused txt5 text"
  task :txt5_clean  => :environment do
     
  #next section does not work, fail on finding Specline
    speclines = Specline.all.collect{|i| i.txt5_id}.uniq
    changes = Change.all.collect{|i| i.txt5_id}.uniq
    txt5_id_array = Txt5.all.collect{|i| i.id}
        
    unused_txt5_id_array = txt5_id_array - changes - speclines

    @unused_txt5 = Txt5.where(:id => unused_txt5_id_array)
     
    @unused_txt5.each do |text|
      text.destroy
    end  
     
  end
  
  desc "remove all session records"
  taks :session_clean   => :environment do
    sessions = Session.all
    sessions.each do |session|
      session.destroy
    end    
  end
    

end