require 'active_record'

namespace :murax do
  desc 'Embargo visible files by work id'
  task :embargo_files_by_work_id, [:workids] => :environment do |task, args|
    if args.count < 1
        puts 'Usage: bundle exec rake murax:embargo_files_by_work_id["<samvera-work-id>[ <samvera-work-id>]..."]'
        next
    end
    workids = args[:workids].split(' ')

    embargo_release_date = DateTime.now.next_year.strftime('%Y-%m-%d')
    abort "0 files were embargoed because one or more invalid work ids were found. Please verify input values and ensure that work ids are submitted as a space separated list." if bad_ids(workids)
    
    embargo_files(workids,embargo_release_date)
    
  end

  def bad_ids(wids)
    puts "#{wids.count} Samvera work ids found"
    bad_ids = 0
    wids.each do |wid|
      if /\A[0-9a-z]{9}\z/ === wid
        next
      else
        puts "invalid work id : #{wid}"
        bad_ids+=1
      end
    end
    return bad_ids
  end

  def embargo_files(wids,embargo_release_date)
    wids.each do |wid|
       begin
          file_sets = ActiveFedora::Base.search_by_id(wid)['human_readable_type_tesim'].first.constantize.find(wid).file_sets
       rescue ActiveFedora::ObjectNotFoundError => e
          puts "Can't find Samvera work #{wid}"
          next
       end
       file_sets.each do |file_set|
         if file_set.visibility == 'open'
            #embargo the file
            puts "embargoing #{file_set.label}"
            file_set.inspect
            begin
               file_set.apply_embargo(embargo_release_date,'restricted','open')
               file_set.save!
            rescue StandardError => e
               puts "error : #{e.message}"
            end
         end
       end
    end 
  end
end
