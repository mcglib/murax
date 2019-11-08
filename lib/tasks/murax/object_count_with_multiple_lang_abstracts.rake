require 'active_record'
require 'optparse'

namespace :murax do
  desc 'Count the objects that have mutiple abstract with the same language.'
  task :object_count_with_multiple_lang_abstracts, [:language] => :environment do |task, args|
    # Making en the default argument.
    if args.count < 1
      language = "@en"
    else
      language =  args.language
      language = language.strip
      language = '@' + language
    end   
    puts "Starting the check for language abstracts with '#{language}' in all works. This might take a while."
    # checking all worktypes. 
    work_types = Article.valid_child_concerns
    types = []
    work_types.each do |wt|
      puts "checkng worktype #{wt}"
      type_objects = []
      wt.find_each do |w|
        abs = w.abstract
        multiple = false
        if abs.count > 1 
          abs_arr = []
          multiple = true
          abs.each do |ab|
            if ab.last(3) == language
              abs_arr << ab
              id = w.id
              title = w.title
            end
          end
        end
        if multiple
          if abs_arr.count > 1
            id = w.id
            title = w.title
            type_objects  << {work_title: title, work_id: id, abstract_count: abs_arr.count}
          end
        end
      end
      types << {"#{wt} WorkType": type_objects, total_works: type_objects.count}
    end

    types.each do |type|
      puts type
    end

    exit
  end
end
