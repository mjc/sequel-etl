#!/usr/bin/env rake
require 'bundler/gem_tasks'

task :console do
  require 'pry'
  require 'lib/sequel-etl'
  ARGV.clear
  Pry.start
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '-b'
  end

  task default: :spec
rescue LoadError
  $stderr.puts "rspec not available, spec task not provided"
end
