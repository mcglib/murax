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
     concern.all.pluck(:abstract, :title, :creator_x).each do |abs, title, cx|
       if abs.respond_to? :each
          abs.each do |abstract|
            lang_code = abstract.match(/\"@(\w{2,3})$/) {|m| m.captures}
            begin
               raise StandardError.new("problem reading creator_x for: #{title}") if cx.first.nil?
               puts "#{cx.first.first.subject.to_s.split('/')[-1].split('#').first} #{lang_code}" if !lang_code.nil? && lang_code.first.length == 2 
            rescue StandardError => e
               puts "#{e}"
            end
          end
       else
          lang_code = abs.match(/\"@(\w{2,3})$/) {|m| m.captures}
          begin
             raise StandardError.new("problem reading creator_x for #{title}") if cx.first.nil?
             puts "#{cx.first.first.subject.to_s.split('/')[-1].split('#').first} #{lang_code}" if ! lang_code.nil? && lang_code.first.length == 2
          rescue StandardError => e
             puts "#{e}"
          end
       end
     end
   end
  end
end
