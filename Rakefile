begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "ruby-oembed"
    gemspec.summary = "oEmbed for Ruby"
    gemspec.description = "A fork of judofyr's ruby-embed library that has been gemefied & updated a bit."
    gemspec.email = "arisbartee@gmail.com"
    gemspec.homepage = "http://github.com/arisbartee/ruby-oembed"
    gemspec.authors = ["Magnus Holm","Alex Kessinger","Aris Bartee","Marcos Wright Kuhns"]
    gemspec.add_dependency("json")
    gemspec.add_dependency("xml-simple")
    gemspec.add_development_dependency("rspec")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end