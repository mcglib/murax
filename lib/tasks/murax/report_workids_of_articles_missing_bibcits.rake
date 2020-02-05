namespace :murax do
  desc 'List work ids of objects of type Article with no data in bibliographic citation'
  task :report_workids_of_articles_missing_bibcits => :environment do |t,args|
     tod = Time.now.strftime('%Y%m%d=%H%M%S')
     logfilename = "log/articles-missing-bibcits-#{tod}.log"
     logfile = File.new(logfilename,'w')
     article_count=0
     Article.all.each do |art|
        if art.bibliographic_citation.first.nil?
           logfile.puts art.id
           article_count += 1
        end
     end
     message = "Found #{article_count} articles with no bibliographic citations"
     puts message
     logfile.puts message
     logfile.close
     puts "Report of work ids available in : #{logfilename}"
  end
end
