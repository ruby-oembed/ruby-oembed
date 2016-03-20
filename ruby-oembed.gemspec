# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'oembed/version'

Gem::Specification.new do |s|
  s.name = 'ruby-oembed'
  s.version = OEmbed::Version.to_s

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Magnus Holm', 'Alex Kessinger', 'Aris Bartee', 'Marcos Wright Kuhns']
  s.date = Date.today.to_s
  s.description = 'An oEmbed consumer library written in Ruby, letting you easily get embeddable HTML representations of supported web pages, based on their URLs. See http://oembed.com for more information about the protocol.'
  s.email = 'webmaster@wrightkuhns.com'
  s.homepage = 'https://github.com/ruby-oembed/ruby-oembed'
  s.licenses = ['MIT']

  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(%r{^(test|spec|features,integration_test)/})

  s.rdoc_options = ['--main', 'README.rdoc', '--title', "ruby-oembed-#{OEmbed::Version}", '--inline-source', '--exclude', 'tasks', 'CHANGELOG.rdoc']
  s.extra_rdoc_files = s.files.grep(/\.rdoc$/) + %w(LICENSE)

  s.require_paths = ['lib']
  s.rubygems_version = '1.8.19'
  s.summary = 'oEmbed for Ruby'

  if s.respond_to? :specification_version
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_development_dependency('rake', ['>= 0'])
      s.add_development_dependency('json', ['>= 0'])
      s.add_development_dependency('xml-simple', ['>= 0'])
      s.add_development_dependency('nokogiri', ['>= 0'])
      s.add_development_dependency('rspec', ['~> 3.0'])
      s.add_development_dependency('vcr', ['~> 1.0'])
      s.add_development_dependency('fakeweb', ['>= 0'])
    else
      s.add_dependency('rake', ['>= 0'])
      s.add_dependency('json', ['>= 0'])
      s.add_dependency('xml-simple', ['>= 0'])
      s.add_dependency('nokogiri', ['>= 0'])
      s.add_dependency('rspec', ['~> 3.0'])
      s.add_dependency('vcr', ['~> 1.0'])
      s.add_dependency('fakeweb', ['>= 0'])
    end
  else
    s.add_dependency('rake', ['>= 0'])
    s.add_dependency('json', ['>= 0'])
    s.add_dependency('xml-simple', ['>= 0'])
    s.add_dependency('nokogiri', ['>= 0'])
    s.add_dependency('rspec', ['~> 3.0'])
    s.add_dependency('vcr', ['~> 1.0'])
    s.add_dependency('fakeweb', ['>= 0'])
  end
end
