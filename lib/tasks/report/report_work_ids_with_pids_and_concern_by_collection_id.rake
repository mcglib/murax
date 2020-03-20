namespace :report do
  desc 'Output work ids, DigiTool PIDs, and Hyrax concern (work type) for a specified Samvera collection'
  task :report_work_ids_with_pids_and_concern_by_collection_id, [:collection] => :environment do |t,args|
    if args.count == 0
      puts "Usage: bundle exec rake report:report_work_ids_with_pids_and_concern_by_collection_id['samvera_collection_id']"
      puts "       output is in tmp as <collection-id>-workids.txt"
      exit
    end
    collection_id = args[:collection]
    if !collection_id.nil? and !collection_id.empty?
      begin
        co = Collection.find(collection_id)
      rescue ActiveFedora::ObjectNotFoundError => e
        puts "Can't find collection with id: '#{collection_id}'"
        puts "available collections: "
        puts "Id (Title)"
        puts "----------"
        Collection.all.each do |coll| puts "#{coll.id} (#{coll.title.first})" end
        exit
      end
    end
 
    if co.member_objects.count == 0
      puts "No works found"
      exit 
    end 

    f='tmp/'+collection_id+'-work-ids.txt'
    count=0
    o=File.open(f,'w')
    co.member_objects.each do |object|
      pid=object.relation.select { |rel| rel.include? "Pid" }
      concern=object.human_readable_type
      o.puts "#{pid.first} #{concern} #{object.id}"
      count+=1
    end
    o.close
    puts "wrote #{count} work ids to #{f}"
  end
end
