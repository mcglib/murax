require 'active_record'

namespace :murax do
  desc 'Deactive embargoes on files by work id'
  task :unembargo_files_by_work_id, [:workids] => :environment do |task,args|
     if args.count < 1
        puts 'Usage: bundle exec rake murax:unembargo_files_by_work_id["<samvera-work-id>[ <samvera-work-id>]..."]'
        next
     end
     workids = args[:workids].split(' ')

     number_of_embargoes_deactivated = 0
     workids.each do |wid|
         number_of_embargoes_deactivated += 1 if unembargo_files(wid.strip)
     end
     puts "#{number_of_embargoes_deactivated} embargoes deactivated on " + workids.count.to_s + " works"
  end

  def unembargo_files(work_id)
     begin
       deactivated_an_embargo = false
       work = ActiveFedora::Base.find(work_id)
       raise StandardError.new("Unable to locate work id: #{work_id}") if work.nil?
       file_sets = work.file_sets
       raise StandardError.new("No files found for work id #{work_id}") if file_sets.nil?
       no_embargoed_files = true
       file_sets.each do |f|
          if f.under_embargo?
             no_embargoed_files = false
             post_embargo_visibility = f.visibility_after_embargo
             f.deactivate_embargo!
             f.embargo.save!
             f.save!
             work.save!
             f.visibility = post_embargo_visibility
             f.save!
             work.save!
             deactivated_an_embargo = !f.under_embargo?
             puts "unembargoed file #{f.id} in work #{work_id}"
          end
          puts "No files to unembargo for work id #{work_id}" if no_embargoed_files
       end
     rescue StandardError => e
       puts e.message
       false
     end
     deactivated_an_embargo
  end
end
