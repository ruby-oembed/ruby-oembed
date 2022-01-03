# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'oembed/version'

Gem::Specification.new do |s|
  s.name = "ruby-oembed"
  s.version = OEmbed::Version.to_s

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Magnus Holm", "Alex Kessinger", "Aris Bartee", "Marcos Wright Kuhns"]
  s.date = Time.now.strftime("%F")
  s.description = "An oEmbed consumer library written in Ruby, letting you easily get embeddable HTML representations of supported web pages, based on their URLs. See http://oembed.com for more information about the protocol."
  s.email = "webmaster@wrightkuhns.com"
  s.homepage = "https://github.com/ruby-oembed/ruby-oembed"
  s.licenses = ["MIT"]

  s.files = `git ls-files`.split("\n").reject { |f| f.start_with?('spec/') || f.start_with?('integration_test/') }

  s.rdoc_options = ["--main", "README.rdoc", "--title", "ruby-oembed-#{OEmbed::Version}", "--inline-source", "--exclude", "tasks", "CHANGELOG.rdoc"]
  s.extra_rdoc_files = s.files.grep(%r{\.rdoc$}) + %w{LICENSE}

  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.19"
  s.summary = "oEmbed for Ruby"

  s.add_development_dependency 'xml-simple', '>= 0'
  s.add_development_dependency 'nokogiri', '>= 0'
end
