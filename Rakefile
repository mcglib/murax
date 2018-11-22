# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

require 'solr_wrapper/rake_task' unless Rails.env.production?






task(:default).clear


# Replace yarn with npm
Rake::Task['yarn:install'].clear if Rake::Task.task_defined?('yarn:install')
Rake::Task['webpacker:yarn_install'].clear
Rake::Task['webpacker:check_yarn'].clear
Rake::Task.define_task('webpacker:verify_install' => ['webpacker:check_npm'])
Rake::Task.define_task('webpacker:compile' => ['webpacker:npm_install'])



#task default: ['ci']

#task :ci do
#  with_server 'test' do
#    Rake::Task['spec'].invoke
#  end
#end
