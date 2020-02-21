class GetRepresentativeFileSetByWorkId
  def self.call(wkid)
    rep_file_set = nil
    begin
      file_sets = ActiveFedora::Base.search_by_id(wkid)['human_readable_type_tesim'].first.constantize.find(wkid).file_sets
      work = ActiveFedora::Base.find(wkid)
      rep_ids = file_sets.map { |p| p.id }
      file_sets.each do | fset|
        # get the main object to be changed
        if work.representative_id == fset.id
             rep_file_set = fset
        end

      end
    rescue ActiveFedora::ObjectNotFoundError => e
       puts "#{e}: #{e.class.name} "
    end
    
    rep_file_set

  end
end
