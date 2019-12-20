require 'active_record'

namespace :murax do
  desc 'Search and replace in a specified field in works belonging to a specified collection'
  task :search_and_replace_in_work_metadata_field_by_collection_id, [:search, :replace, :field, :collection_id] => :environment do |task, args|
     usage_message="Usage: bundle exec rake murax:search_and_replace_in_work_metadata_field_by_collection_id[<search-term>,<replace-term>,<field>,<collection-id>]"
     if args.count < 4
        puts usage_message
        exit
     end
     search_val = args[:search] if !args[:search].nil?
     replace_val = args[:replace] if !args[:replace].nil?
     target_field = args[:field] if !args[:field].nil?
     collid = args[:collection_id] if !args[:collection_id].nil?

     begin
        co = Collection.find(collid)
     rescue ActiveFedora::ObjectNotFoundError => e
        puts "Can't find collection with id: #{collid}"
        puts "Available collections: "
        puts "Id (Title)"
        puts "----------"
        Collection.all.each do |coll| puts "#{coll.id} (" + coll.title.first + ")" end
        exit
     end

     if !collid.nil?
        collection_object = Collection.find(collid)
        count=0
        collection_object.member_objects.each do |obj|
           wid = obj.id
           active_fedora_solr_hit = ActiveFedora::Base.search_by_id(wid)
           if active_fedora_solr_hit.nil?
              puts "#{wid} not found"
              next
           else
              obj = active_fedora_solr_hit['human_readable_type_tesim'].first.constantize.find(wid)
              SearchAndReplaceInFieldOfObject.new(search_val, replace_val, target_field, obj)
              count+=1
           end
        end
        puts "Processed #{count} works"
     end
  end

end
