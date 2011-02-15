desc "Generate RDoc"
task :doc => ['doc:generate']

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  require 'bluecloth'

  namespace :doc do
    project_root = File.expand_path(File.join(File.dirname(__FILE__)))
    doc_destination = File.join(project_root, 'doc', 'rdoc')

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
  end
rescue LoadError
  namespace :doc do
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please `gem install yard bluecloth` to generate rdoc."
    end
  end
end
