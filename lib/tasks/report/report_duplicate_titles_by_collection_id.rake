namespace :report do
  desc 'Output titles and work ids of possible duplicates'
  task :report_duplicate_titles_by_collection_id, [:collectionid, :output_file] => :environment do |t,args|
    if args.count < 1
       puts 'Usage: bundle exec rake report:report_duplicate_titles_by_collection_id[<collectionid>[,output-file]]'
       puts '       Output is written to tmp directory. If no filename is provided as the 2nd argument output is written to tmp/duplicate-titles.txt'
       exit
    end
    collection_id = args[:collectionid]

    begin
        co = Collection.find(collection_id)
    rescue ActiveFedora::ObjectNotFoundError => e
        puts "Can't find collection with id: #{collection_id}"
        puts "Available collections: "
        puts "Id (Title)"
        puts "----------"
        Collection.all.each do |coll| puts "#{coll.id} (" + coll.title.first + ")" end
        exit
    end

    if !args[:output_file].nil?
      fn = 'tmp/'+args[:output_file]
    else
      fn = 'tmp/duplicate-titles.txt'
    end


    duplicate_titles = ReportDuplicateTitlesByCollectionIdService.new(collection_id).duplicate_titles  

    o=File.open("#{fn}",'w')
    if !duplicate_titles.nil?
      duplicate_titles.each do |ti|
         o.puts "#{ti}" 
      end
    else
      puts "No duplicates found"
    end
    o.close if !fn.nil?
    puts "wrote #{duplicate_titles.count} possible duplicated titles to #{fn}" if !duplicate_titles.nil?

  end

end
