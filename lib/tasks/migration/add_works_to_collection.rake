namespace :migration do
    desc 'Migrate a Digitool object with a PID and its related items eg: bundle exec rake migrate:import_record[pid]'
    task :add_work_to_collection, [:work_id, :work_type, :collection_id] => :environment do |t, args|
      if args.count < 3
        puts "Usage: bundle exec rake migration:add_work_to_collection['work_id','Thesis','theses']"
        puts "Expecting three arguments found #{args.count}"
        exit
      end

      #check if collection exists
      existing_collection = Collection.find(args[:collection_id])
      if existing_collection == nil
        puts "error: Collection '#{args[:collection_id]}' does not exist."
        exit
      end


      start_time = Time.now
      puts "[#{start_time.to_s}] Adding the work: #{args[:work_id]}"

      begin
        # Get the work
        work = args[:work_type].singularize.classify.constantize
        #check if work  exists
        work = work.find(args[:work_id])
        if existing_work == nil
          puts "error: Work with id: '#{args[:work_id]}' does not exist."
        end

        AddWorkToCollection.call(args[:work_id],args[:work_type], args[:collection_id])
      rescue ActiveFedora::ObjectNotFoundError
          puts "error: Work with id: '#{args[:work_id]}' does not exist."
          exit
      rescue Exception 
          puts "Error occurred adding the work to the collection #{args[:collection_id]}. #{e}"
          exit
      end

      puts "Added the workid: #{args[:work_id]} of type: #{args[:work_type]} to the collection '#{args[:collection_id]}'"

      exit
    end
end
