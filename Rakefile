# frozen_string_literal: true
require 'rubocop/rake_task'

task default: %w[lint run]

RuboCop::RakeTask.new(:lint) do |task|
    task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
    task.fail_on_error = false
end

task :run do
  cd 'lib/'
  ruby 'challenge.rb'
end

task :test do
  bundle exec 'rspec'
end