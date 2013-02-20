#bundle exec rake cleanup:remove_unused_records
#*** cd/datat/myapp/current && /lib/tasks cleanup RAILS_ENV = product

namespace :cleanup do

 desc "remove unused records from database"
 task :remove_unused_records => [:txt3_clean, :txt4_clean, :txt5_clean, :clausetitle_clean, :session_clean] do 
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
  
  
  desc "remove unused clausetitles"
  task :clausetitle_clean  => :environment do
     
  #next section does not work, fail on finding Specline
    clauses = Clause.all.collect{|i| i.clausetitle_id}.uniq
    clausetitle_id_array = Clausetitle.all.collect{|i| i.id}
        
    unused_clausetitle_id_array = clausetitle_id_array - clauses

    @unused_clausetitle = Clausetitle.where(:id => unused_clausetitle_id_array)
     
    @unused_clausetitle.each do |title|
      title.destroy
    end  
     
  end
  
  
  desc "remove all session records"
  task :session_clean   => :environment do
    @sessions = Session.where('created_at > ?', 1.day.ago)
    @sessions.each do |session|
      session.destroy
    end    
  end
    
end