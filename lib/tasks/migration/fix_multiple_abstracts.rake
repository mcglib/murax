namespace :migration do
  desc 'Replace multiple abstracts of specific language with single abstract from xml'
  task :fix_multiple_abstracts, [:xml_file, :lang] => :environment do |t,args|
     xml_file = args[:xml_file]
     begin
       raise ArgumentError.new("Missing required argument (name of xml file in tmp directory).") if xml_file.nil?
       abstract_file = Nokogiri::XML(File.open('tmp/'+xml_file)) do |conf| conf.strict.noblanks end
       work_id = nil
       puts abstract_file.root.children.count.to_s + " works found in file"
       abstract_file.root.children.each do |work| 
         new_abstracts = []
         work.children.each do |node|
           work_id = node.text.strip if node.name == 'work_id'
           new_abstracts << '"' + node.text + '"@' + node['lang'] if node.name == 'abstract'
         end
         begin
            thesis = Thesis.find(work_id)
         rescue
            puts "Failed to find object #{work_id}"
            next
         end
         thesis['abstract'] = new_abstracts
         thesis.save
         puts "Updated #{work_id}"
       end
     rescue ArgumentError, StandardError => e
       puts e.message
     end
  end
end
