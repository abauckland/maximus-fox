#bundle exec rake cleanup:txt3_clean
#*** cd/datat/myapp/current && /lib/tasks cleanup RAILS_ENV = product

namespace :cleanup do

 desc "remove unused records from database"
 task :remove_unused_records => [:txt3_clean] do 
 end 
 
 desc "remove unused txt3 text"
 task :txt3_clean do
		 
	#next section does not work, fail on finding Specline
	speclines = Specline.all.collect{|i| i.txt3_id}.uniq
    changes = Change.all.collect{|i| i.txt3_id}.uniq
    txt3_id_array = Txt3.all.collect{|i| i.id}
    
    Txt3.joins(:speclines, :changes).where
    
    unused_txt3_id_array = txt3_id_array - changes - speclines

    @unused_txt3 = Txt3.where(:id => unused_txt3_id_array)
		 
	@unused_txt3.each do |text|
		text.destroy
	end	 
		 
 end

end