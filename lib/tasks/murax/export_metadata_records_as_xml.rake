require 'active_record'
require 'optparse'
require 'uri'

namespace :murax do
  desc 'Export one or more metadata records as xml'
  task :export_metadata_records_as_xml, [:destination] => :environment do |task, args|
    dest = args.destination
    workids = args.extras
    if dest.empty? or workids.empty?
      puts "Usage: bundle exec rake murax:export_metadata_records_as_xml['destination-of-output','work_id'[,'work-id'...]]"
      puts "       Exports the metadata for the specified record(s) as xml"
      puts "       Suppy a filename or 'stdout' as the first argument. Files will be written to tmp directory."
      puts "Expecting two arguments; found #{args.count}."
      puts args
      exit
    end

    # We assume that nested ordered elements are always stored as hashes with one key always called 'index' (the value is an int specifying output order)
    #  and a second key which is the name of the ordered field (the value is the value of the ordered field). Therefore we only store the name of the second key in the hash below 
    nested_ordered_elements = { "nested_ordered_creator"=>"creator" }
    ignored_elements = ["head","tail","creator_x"]

    ordered_field_regex = /<([a-z-]+)([0-9]+)>([^<]+)/i

    if !dest.downcase.eql? 'stdout'
       o=File.open('tmp/'+dest,'w')
    else
       o=$stdout.dup
    end

    o.puts "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"
    o.puts "<records>"

    workids.each do |work_id|
       #fetch object
       begin
          work = ActiveFedora::Base.find(work_id)
       rescue ActiveFedora::ObjectNotFoundError
          o.puts "<record><error>couldn't find work_id "+work_id+"</error></record>"
          next
       end

       #transform to xml
       temphash = {}
    
       work.attributes.each do |name, value|
          if !value.nil? && !ignored_elements.include?(name)
            if nested_ordered_elements.key?(name)
               nameh={}
               value.entries.each do |entry|
                 nameh[entry['index'].first]=entry[nested_ordered_elements[name]].first
               end
               value.count.times {|i| temphash['creator'+i.to_s] = nameh[i.to_s]}
            else
              if value.instance_of? String
                 temphash[name] = value
              else
                 if value.count > 1
                    value.count.times {|i| temphash[name+i.to_s] = value.entries[i]}
                 else
                    temphash[name] = value.entries.first
                 end
              end 
            end
          end 
       end

       #output xml
       xml=temphash.to_xml(:root=>'record',:skip_instruct => true)
       xml.each_line do |xml_line|
         if xml_line =~ ordered_field_regex
           o.puts "<"+$1+" order=\""+$2+"\">"+$3+"</"+$1+">"
         else
           o.puts xml_line
         end
       end
     end

     o.puts "</records>"
     o.close
     exit
   end
end
