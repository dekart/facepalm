require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name = 'facepalm'
    gem.summary = "Facebook integration for Rack & Rails application"
    gem.email = "rene.dekart@gmail.com"
    gem.homepage = "http://github.com/dekart/#{ gem.name }"
    gem.authors = ["Aleksey Dmitriev"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end