namespace :murax do
  desc 'test FetchAFile service'
  task :fetch_a_file_by_file_id, [:arg] => :environment do |t,arg|
    f = arg[:arg]
    faf = FetchAFile.new
    faf.by_file_id(f)

    if faf.fetch_error?
       puts faf.get_error_message
    else
       puts "successfully fetched " + faf.fetched_file_name
    end
  end
end
