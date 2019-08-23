require 'active_record'
require 'optparse'
namespace :murax do
  #bundle exec rake murax:create_digitool_collections -- -f config/digitool_collections.json --owner dev.library.mcgill.ca
  desc 'Fixity check'
  task :fixity_check => :environment do
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
    exit
  end

end

