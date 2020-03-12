require 'active_record'
require 'optparse'

namespace :murax do
  desc 'Report ids of works with abstracts carrying a two-letter lang tag.'
  task :report_two_letter_lang_tags_in_abstracts => :environment do |task, args|

   puts "Starting the check for abstracts with two-letter language tags. This might take a while."   
   Hyrax.config.curation_concerns.each do |concern|
     puts "Checking the worktype #{concern} "
     concern.all.pluck(:abstract, :head).each do |abs, head|
       if abs.respond_to? :each
          abs.each do |abstract|
            lang_code = abstract.match(/\"@(\w{2,3})$/) {|m| m.captures}
            puts "#{head.first.id.split('/')[-2]} #{lang_code}" if lang_code.first.length == 2 
          end
       else
          lang_code = abs.match(/\"@(\w{2,3})$/) {|m| m.captures}
          puts "#{head.first.id.split('/')[-2]} #{lang_code}" if lang_code.first.length == 2
       end
     end
   end
  end
end
