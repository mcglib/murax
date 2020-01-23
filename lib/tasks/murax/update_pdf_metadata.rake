require 'active_record'

namespace :murax do
  desc 'Update a pdfs metadata when the workids  are passed to it'
  task :update_pdf_metadata, [:pdffilepath] => :environment do |task, args|
    if args.count < 1
        puts 'Usage: bundle exec rake murax:update_pdf_metadata["<samvera-work-id>[ <samvera-work-id>]..."]'
        next
    end
    faf = FetchAFile.new
    faf.by_uri(f)
  end
end
