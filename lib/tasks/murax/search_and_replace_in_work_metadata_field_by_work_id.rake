require 'active_record'

namespace :murax do
  desc 'Search and replace in a specified field'
  task :search_and_replace_in_work_metadata_field_by_work_id, [:search, :replace, :field, :workids] => :environment do |task, args|
     usage_message="Usage: bundle exec rake murax:search_and_replace_in_work_metadata_field[<search-term>,<replace-term>,<field>[,'workid workid workid']]\n"
     usage_message+='Leading and trailing spaces must be escaped. E.g. to replace the word "duct" with the word "pipe" use "\ duct\ " and "\ pipe\ "'
     usage_message+=' to avoid turning "products" into "propipes", etc.'
     if args.count < 4
        puts usage_message
        exit
     end
     search_val = args[:search] if !args[:search].nil?
     replace_val = args[:replace] if !args[:replace].nil?
     target_field = args[:field] if !args[:field].nil?
     workids = args[:workids].split(' ') if !args[:workids].nil?

     if !workids.nil?
        count=0
        workids.each do |wid|
           begin 
             active_fedora_solr_hit = ActiveFedora::Base.search_by_id(wid)
             if active_fedora_solr_hit.nil?
                puts "#{wid} not found"
                next
             else
                obj = active_fedora_solr_hit['human_readable_type_tesim'].first.constantize.find(wid)
                SearchAndReplaceInFieldOfObject.new(search_val, replace_val, target_field, obj)
                count+=1
             end
           rescue ActiveFedora::ObjectNotFoundError => e
             puts "#{wid} not found"
           end
        end
        puts "Processed #{count} work ids"
     end
  end
end
