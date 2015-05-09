$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: [:test, :rubocop]
