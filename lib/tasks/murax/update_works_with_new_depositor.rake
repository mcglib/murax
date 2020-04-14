require 'active_record'

namespace :murax do
  desc 'Update a set of work ids with a new depositor(using email address)'
  task :update_works_with_new_depositor, [:new_user,:workids] => :environment do |task, args|
     usage_message="Usage: bundle exec rake murax:update_works_with_new_depositor[new_user,'workid workid workid']\n"
     if args.count < 2
        puts usage_message
        exit
     end
     new_user_val = args[:new_user] if !args[:new_user].nil?
     workids = args[:workids].split(' ') if !args[:workids].nil?

     if !workids.nil?
        count=0
        workids.each do |wid|
           begin 
             puts "Processing #{wid}"
             solr_hit = ActiveFedora::Base.search_by_id(wid)
             if solr_hit.nil?
                puts "#{wid} not found"
                next
             else
                obj = solr_hit['human_readable_type_tesim'].first.constantize.find(wid)
                obj.depositor = new_user_val
                obj.save!
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
