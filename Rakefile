# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

# Get all files in /app/views/page ending with md
SOURCE_FILES = Rake::FileList.new("app/views/docs/*md")

# Define a task
task :compile_md => SOURCE_FILES.pathmap("%X.html.erb")

# Define rule for the task
rule '.html.erb' => SOURCE_FILES do |t|
  require 'kramdown'
  content = Kramdown::Document.new(File.read(t.source)).to_html
  File.write(t.name, content)
end
