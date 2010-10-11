begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "ruby-oembed"
    gemspec.summary = "oEmbed for Ruby"
    gemspec.description = "An oEmbed client written in Ruby, letting you easily get embeddable HTML representations of a supported web pages, based on their URLs. See http://oembed.com for more about the protocol."
    gemspec.email = "arisbartee@gmail.com"
    gemspec.homepage = "http://github.com/judofyr/ruby-oembed"
    gemspec.authors = ["Magnus Holm","Alex Kessinger","Aris Bartee","Marcos Wright Kuhns"]
    gemspec.add_dependency("json")
    gemspec.add_dependency("xml-simple")
    gemspec.add_development_dependency("rspec")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end