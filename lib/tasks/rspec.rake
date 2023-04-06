require "rspec/core/rake_task"
require "standard/rake"

RSpec::Core::RakeTask.new(:specs)

task default: [:specs, :standard]
