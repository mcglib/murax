namespace :murax do
  desc 'test FetchAFile service'
  task :fetch_a_file_by_uri, [:arg] => :environment do |t,arg|
    f = arg[:arg]
    faf = FetchAFile.new(f)
    faf.by_uri

    if faf.fetch_error?
      puts faf.get_error_message
    end 
  end
end
