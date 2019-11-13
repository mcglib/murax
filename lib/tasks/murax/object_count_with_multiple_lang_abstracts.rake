require 'active_record'
require 'optparse'

namespace :murax do
  desc 'Count the objects that have mutiple abstract with the same language.'
  task :object_count_with_multiple_lang_abstracts, [:language] => :environment do |task, args|
    # Making en the default argument.
    if args.count < 1
      language = "@en"
    else
      language =  args.language
      language = language.strip
      language = '@' + language
    end  
   puts "Starting the check for language abstracts with '#{language}' in all works. This might take a while."   
   final_arr =[]
   Hyrax.config.curation_concerns.each do |concern|
     puts "Checking the worktype #{concern} "
     concern_arr = []
     concern.all.pluck(:abstract).each do |abs|
       if !abs.blank?
         multiple = false
         if abs.count > 1
           ab_arr = []
           abs.each do |ab|
             if ab.last(3) == language
               multiple = true
               ab_arr << ab
             end             
           end
           if multiple
             if ab_arr.count > 1
               work_id = abs.parent.id
               work_id = work_id.split("/")
               work_id =  work_id.last 
               abstract_count = ab_arr.count
               concern_arr << {work_id: work_id, abstract_count: abstract_count}
             end
           end
         end
       end
     end
     final_arr << {"#{concern}": concern_arr, total_works: concern_arr.count}
   end
   
   final_arr.each do |type| 
     puts type
   end
   
   exit
  end
end
