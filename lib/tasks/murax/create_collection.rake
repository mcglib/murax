require 'active_record'
require "#{Rails.root}/app/services/find_or_create_collection.rb" # <-- HERE!
namespace :murax do

  desc 'Create a collection using a given slug'
  task :create_collection, [:slug, :title, :owner, :collection_type] => :environment do |t, args|
    args.with_defaults(:collection_type => 'User Collection', :owner => ENV['ADMIN_EMAIL'])

    if args.count < 3
      puts "Usage: bundle exec rake murax:create_collection['slug','collection_type','email_address', 'title']"
      puts "Expecting minimum three arguments found #{args.count}"
      exit
    end

    #check :slug
    if args[:slug].nil? || args[:slug].length < 3
      puts "Error: Please enter the slug name.it should be least 3 characters long"
      exit
    end

    #check :title
    if args[:title].nil? || args[:title].length < 10
      puts "Error: Please enter the title of the collection.it should be least 10 characters long"
      exit
    end

    #check :collection_type
    if args[:collection_type].nil? || args[:collection_type].length < 10
      puts "Error: Please enter the name of the collection type the collection will belong to.it should be least 10 characters long"
      exit
    end


    collection_attributes = {
      visibility: 'open',
      id: args[:slug],
      title: [args[:title]],
      collection_type_gid:  FindOrCreateCollection.get_collection_type_gid(args[:collection_type])
    }
    #return `ARGV` with the intended arguments
    begin
      existing = Collection.where id: args[:slug]
      raise StandardError "The collection #{existing.first.title} already exists" if existing.first

      col = Collection.new collection_attributes
      @user = User.where(:email => args[:owner]).first
      col.apply_depositor_metadata @user
      col.save!

       puts "Added the collection  :#{col.slug} to the collection type: #{args[:collection_type]}"
    rescue StandardError => e
      puts "Error creating the collection #{args[:slug]}: #{e}: #{e.class.name}"
    end
    exit
  end

end
