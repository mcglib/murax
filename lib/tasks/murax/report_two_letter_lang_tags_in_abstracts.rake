require 'active_record'
require 'optparse'

namespace :murax do
  desc 'Report ids of works with abstracts carrying a two-letter lang tag.'
  task :report_two_letter_lang_tags_in_abstracts, [:concern] => :environment do |task, args|

   concerns_to_check = Array.new
   concern_argument = args[:concern]
   if concern_argument.nil?
      concerns_to_check = Hyrax.config.curation_concerns
   else
      concerns_to_check << concern_argument.constantize
   end
   puts "Starting the check for abstracts with two-letter language tags. This might take a while."   
   concerns_to_check.each do |concern|
     puts "Checking the worktype #{concern} "
     concern.all.pluck(:abstract, :head, :title).each do |abs, head, title|
       if abs.respond_to? :each
          abs.each do |abstract|
            lang_code = abstract.match(/\"@(\w{2,3})$/) {|m| m.captures}
            begin
               raise StandardError.new("problem reading head for: #{title}") if head.first.nil?
               puts "#{head.first.id.split('/')[-2]} #{lang_code}" if !lang_code.nil? && lang_code.first.length == 2 
            rescue StandardError => e
               puts "#{e}"
            end
          end
       else
          lang_code = abs.match(/\"@(\w{2,3})$/) {|m| m.captures}
          begin
             raise StandardError.new("problem reading head for #{title}") if head.first.nil?
             puts "#{head.first.id.split('/')[-2]} #{lang_code}" if ! lang_code.nil? && lang_code.first.length == 2
          rescue StandardError => e
             puts "#{e}"
          end
       end
     end
   end
  end
end
