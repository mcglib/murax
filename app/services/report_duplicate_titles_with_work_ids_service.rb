class ReportDuplicateTitlesWithWorkIdsService
    @duplicate_titles = Array.new
    @duplicate_titles_and_workids = Hash.new
    @collection = nil
    
  def initialize(collection_id)
    @cid = collection_id
    @collection = Collection.new    
  end

  def duplicate_titles()
    hash_of_titles = build_hash_of_titles(@cid)
    @array_of_duplicate_titles = build_array_of_duplicate_titles(hash_of_titles) if hash_of_titles.count > 0
    if !@array_of_duplicate_titles.nil?
      @duplicate_titles_and_workids = add_work_ids(@array_of_duplicate_titles,hash_of_titles) if @array_of_duplicate_titles.count > 0
    end
    @duplicate_titles_and_workids
  end

  private

  def build_hash_of_titles(cid)
     @collection = Collection.find(cid)
     h = Hash.new
     @collection.member_objects.each do |co|
        h[co.id] = co.title.first.strip
     end
     h
  end
        
  def build_array_of_duplicate_titles(h)
     nh=Hash.new(0)
     dups=Array.new
     h.each do |k,v|
        nh[v]+=1
     end
     nh.each do |k,v|
        dups << k if v>1
     end
     dups
  end

  def add_work_ids(array_of_dups,hash_of_titles)
      dup_hash=Hash.new
      array_of_dups.each do |title|
         hash_of_titles.select{ |k,ti| ti == title}.keys.each do |ky|
           dup_hash[ky] = title
         end
      end
      dup_hash
  end
end
