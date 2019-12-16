namespace :report do
  desc 'Output work ids for a specified filename'
  task :report_work_ids_by_filename, [:filenames] => :environment do |t, args|
    if args.count < 1
       puts 'Usage: bundle exec rake report:report_work_ids_by_filename["<filename>[ <filename>]..."]'
       exit
    end
    filenames = args[:filenames].split(' ')

    puts "checking #{filenames.count} file names"

    filenames.each do |fname|
       samvera_work_ids = ReportWorkidsService.by_filename(fname)
       puts "#{samvera_work_ids.join(',')} #{fname}"
    end
  end
end
