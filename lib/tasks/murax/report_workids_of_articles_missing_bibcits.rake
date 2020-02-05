namespace :murax do
  desc 'List work ids of objects of type Article with no data in bibliographic citation'
  task :report_workids_of_articles_missing_bibcits => :environment do |t,args|
     article_count=0
     Article.all.each do |art|
        if art.bibliographic_citation.first.nil?
           puts art.id
           article_count += 1
        end
     end
     puts "Found #{article_count} articles with no bibliographic citations"
  end
end
