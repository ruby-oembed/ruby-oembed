require 'lib/oembed/version'

begin
  require 'jeweler'
  
  Dir[File.join(File.dirname(__FILE__), "lib/tasks/*.rake")].sort.each { |ext| load ext }
  
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "ruby-oembed"
    gemspec.version = OEmbed::VERSION
    gemspec.homepage = "http://github.com/judofyr/ruby-oembed"
    gemspec.summary = "oEmbed for Ruby"
    gemspec.description = "An oEmbed client written in Ruby, letting you easily get embeddable HTML representations of supported web pages, based on their URLs. See http://oembed.com for more information about the protocol."
    gemspec.license = "MIT"
    gemspec.email = "arisbartee@gmail.com"
    gemspec.authors = ["Magnus Holm","Alex Kessinger","Aris Bartee","Marcos Wright Kuhns"]
    gemspec.add_development_dependency("json")
    gemspec.add_development_dependency("xml-simple")
    gemspec.add_development_dependency("rspec")
    gemspec.add_development_dependency("yard")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

desc "Generate RDoc"
task :doc => ['doc:generate']

namespace :doc do
  project_root = File.expand_path(File.join(File.dirname(__FILE__)))
  doc_destination = File.join(project_root, 'doc', 'rdoc')
  
  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      yt.options = [
        '--output-dir', doc_destination,
        '--title', "Documentation for ruby-oembed #{OEmbed::VERSION}",
      ]
    end
  
    desc "Remove generated documenation"
    task :clean do
      puts project_root.inspect
      #rm_r doc_dir if File.exists?(doc_destination)
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please install the YARD gem to generate rdoc."
    end
  end
end
