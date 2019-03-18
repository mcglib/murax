require 'active_record'
require 'optparse'
namespace :murax do
  #bundle exec rake murax:create_digitool_collections -- -f config/digitool_collections.json --owner dev.library.mcgill.ca
  desc 'Create the default collections via a json file'
  task :create_digitool_collections => :environment do
    require "#{Rails.root}/app/services/find_or_create_collection.rb" # <-- HERE!
    options = {
          file: 'config/digitool_collections.json',
          owner: 'dev.library@mcgill.ca'
    }
    o = OptionParser.new
    o.banner = "Usage: rake create_digitool_collections [options]"
    o.on('-f FILENAME', '--filename FILENAME') { |file|
      options[:file] = file
    }
    o.on('-o EMAIL', '--owner EMAIL') { |owner|
      options[:owner] = owner
    }
    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)
    puts "hello #{options.inspect}"
    
    collection_metadata = JSON.parse(File.read(File.join(Rails.root, options[:file])))
    collection_metadata.each do |c|
      slug = c['slug']
      if c['slug'].present?
        collection = FindOrCreateCollection.create(slug, options[:owner])
        puts "Added the collection  :#{c['title']} to the collection type: #{c['collection_type']}"
      end
    end
    puts "Added the  user :#{options[:full_name]} to the role 'admin'"
    exit
  end

end

