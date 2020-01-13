namespace :murax do
  desc 'test FetchAFile service'
  task :fetch_a_file_by_uri, [:arg] => :environment do |t,arg|
    f = arg[:arg]
    faf = FetchAFile.new
    faf.by_uri(f)

    if faf.fetch_error?
      puts faf.get_error_message
    else 
      puts "successfully fetched " + faf.fetched_file_name
    end 
  end
end
