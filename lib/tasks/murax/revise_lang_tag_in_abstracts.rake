require 'active_record'

namespace :murax do
  desc 'Revise language tag in abstracts according to target (2 or 3). If target=2 tags will be "en" or "fr", if target=3 tags will be "eng" or "fre"'
  task :revise_lang_tag_in_abstracts, [:target, :workids] => :environment do |task, args|
     usage_message="Usage: bundle exec rake murax:revise_lang_tag_in_abstracts[target,'workid[ workid ...']]\n"
     if args.count < 1
        puts usage_message
        exit
     end
     target = args[:target]
     workids = args[:workids].split(' ') if !args[:workids].nil?
     raise ArgumentError.new("Illegal value #{target} for target") if !target.to_i.between?(2,3)

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
                abstracts = obj['abstract']
                if abstracts.respond_to? :each
                   new_abstracts = Array.new
                   abstracts.each do |abs|
                       new_abstracts << revise_lang_code(abs,target)
                   end
                else
                   new_abstracts = ''
                   new_abstracts = revise_lang_code(abstracts,target)
                end
                obj['abstract'] = new_abstracts
                obj.save
                count+=1
             end
           rescue ActiveFedora::ObjectNotFoundError => e
             puts "#{wid} not found"
           end
        end
        puts "Processed #{count} work ids"
     end
  end

  def revise_lang_code(abstract,target)
      revised_abstract = abstract
      english = {'2' => 'en', '3' => 'eng'}
      french =  {'2' => 'fr', '3' => 'fre'}
      lang_code = abstract.match(/\"@(\w{2,3})$/) {|m| m.captures}
      if !lang_code.nil?
         case lang_code.first.downcase
           when "en","eng"
             new_code = english[target]
           when "fr","fre"
             new_code = french[target]
           else
             new_code = lang_code.first.downcase
         end
         revised_abstract = revised_abstract.gsub(/\"@\w{2,3}$/,"\"@#{new_code}")
      end
      revised_abstract
  end

end
