require 'rspec/core/rake_task'

# For some reason, Travis CI continues to fail when VCR is enabled,
# so as a short-term fix well just disable VCR when we run the test
# via travis. This lets local tests run quickly and Travis tests
# correctly show as green.
if ENV['TRAVIS']
  ENV['NO_VCR'] = 'true'
end

RSpec::Core::RakeTask.new(:specs)

task :default => :specs