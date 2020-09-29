namespace :report do
  desc 'Output total filesize of files meeting the specified criteria for a specified collection id'
  task :report_total_filesize_by_collectionid, [:filetype, :fileformat, :accessibility, :collectionid] => :environment do |t,args|
    @usage = "Usage: bundle exec rake report:report_filesize_by_workid['<representative_media|other>, <any|image|audio|video|pdf|office_document>, <public|private>, <collection id>']"
    if args.count < 4
       puts "#{@usage}"
       puts "#{args.count} args received"
       exit
    end
    begin
      @total_filesize = 0
      ftype = args[:filetype]
      raise ArgumentError.new("Invalid file type '#{ftype}'\n#{@usage}") if ! ['representative_media','other'].include? ftype
      fformat = args[:fileformat]
      raise ArgumentError.new("Invalid file format '#{fformat}'\n#{@usage}") if ! ['any','image','audio','video','pdf','office_document'].include? fformat
      faccess = args[:accessibility]
      raise ArgumentError.new("Invalid specificiation for accessibility '#{faccess}'\n#{@usage}") if ! ['public','private'].include? faccess
      cid = args[:collectionid]
      collection = Collection.find(cid)

      collection.member_objects.each do |object|
        next if object.is_a? Collection
        wid = object.id
        file_sets = ActiveFedora::Base.search_by_id(wid)['human_readable_type_tesim'].first.constantize.find(wid).file_sets
        file_sets.each do |file_set|
          fileset_is_representative_media = file_set.parent.representative_id == file_set.id
          next if !file_set.public_send(faccess+'?')
          if fformat != 'any'
             next if !file_set.public_send(fformat+'?')
          end
          next if ftype == 'representative_media' && ! fileset_is_representative_media
          next if ftype == 'other' && fileset_is_representative_media
          @total_filesize += file_set.file_size.first.to_i 
        end
      end
      f='tmp/'+cid+'-total-filesize.txt'
      o=File.open(f,'w')
      o.puts "total filesize for #{cid} (#{ftype}, #{fformat}, #{faccess}): #{@total_filesize}"
      o.close
      puts "#{@total_filesize}"
    rescue ArgumentError, ActiveFedora::ObjectNotFoundError, StandardError => e
      puts "error: #{e.message}";
    end
  end
end
