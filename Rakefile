require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default do
  sh "RAILS=2.3.12 && (bundle || bundle install) && bundle exec rake test"
  sh "RAILS=3.0.10 && (bundle || bundle install) && exec rake test"
  sh "RAILS=3.1.2 && (bundle || bundle install) && exec rake test"
  sh "git checkout Gemfile.lock"
end

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name = 'facepalm'
    gem.summary = "Facebook integration for Rack & Rails application"
    gem.email = "rene.dekart@gmail.com"
    gem.homepage = "http://github.com/dekart/facepalm"
    gem.authors = ["Aleksey V. Dmitriev"]

    gem.add_dependency "koala", '~> 1.11.1'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end