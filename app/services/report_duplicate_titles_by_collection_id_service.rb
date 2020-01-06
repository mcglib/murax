class ReportDuplicateTitlesByCollectionIdService
    @duplicate_titles = Array.new
    @collection = nil
    
  def initialize(collection_id)
    @cid = collection_id
    @collection = Collection.new    
  end

  def duplicate_titles()
    array_of_titles = build_array_of_titles(@cid)
    @duplicate_titles = find_duplicate_titles(array_of_titles) if array_of_titles.count > 0
    @duplicate_titles
  end

  private

  def build_array_of_titles(cid)
     @collection = Collection.find(cid)
     a = Array.new
     @collection.member_objects.each do |co|
        a << co.title.first.strip
     end
     a
  end
        
  def find_duplicate_titles(a)
     h=Hash.new(0)
     dups=Array.new
     a.each do |t|
        h[t]+=1
     end
     h.each do |k,v|
        dups << k if v>1
     end
     dups
  end

end
