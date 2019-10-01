namespace :migration do
    require 'fileutils'
    require 'htmlentities'
    require 'csv'
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

      added = add_work_to_collection(args[:work_id], args[:work_type], args[:collection_id])
      puts "Added the workid: #{args[:work_id]} of type: #{args[:work_type]} to the collection '#{args[:collection_id]}'" if added
      puts "Error: Failed to add the workid: #{args[:work_id]} of type: #{args[:work_type]} to the collection '#{args[:collection_id]}'" if !added

      exit
    end

    desc 'Migrate a Digitool object with a PID and its related items eg: bundle exec rake migrate:import_record[pid]'
    task :bulk_add_works_to_collection, [:work_file, :work_type, :collection_id] => :environment do | t, args|
      if args.count < 3
        puts "Usage: bundle exec rake migration:bulk_add_works_to_collection[filelist.txt,'Thesis','theses']"
        puts "Expecting three arguments found #{args.count}"
        exit
      end
      @work_list = File.read("#{Rails.root}/#{args[:work_file]}").strip.split("\n")

      successes = 0
      errors = 0
      @work_list.each do |work_id|
        begin
          puts "executing #{work_id}"
          added = add_work_to_collection(work_id, args[:work_type], args[:collection_id])
          #added = true
          successes += 1 if added
        rescue StandardError => e
          puts "#{e}"
          errors += 1
        end
      end

      puts "Processed #{successes} work(s), #{errors} error(s) encountered"

      exit

    end

    def add_work_to_collection(work_id, work_type, collection_id)
      added = true
      begin
        # Get the work
        work = work_type.singularize.classify.constantize
        #check if work  exists
        work = work.find(work_id)
        raise StandardError  "error: Work with id: '#{work_id}' does not exist." if work.nil?

        collectionObj = Collection.find(collection_id)
        collectionObj.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX

        added = AttachWorkToCollection.call(work_id, work_type, collectionObj)

      rescue ActiveFedora::ObjectNotFoundError
          puts "error: Work with id: '#{work_id}' does not exist."
          added = false
      rescue Exception => e
          puts "Error occurred adding the work to the collection #{collection_id}. #{e}"
          added = false
      rescue StandardError => e
          puts "Error occurred adding the work to the collection #{collection_id}. #{e}"
          added = false
      end

      added

    end
end
