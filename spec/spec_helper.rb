require 'rubygems'

require 'vcr'
VCR.configure do |c|
  c.default_cassette_options = { :record => :new_episodes }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  # Try to prevent a real-world Facebook token from being recorded by VCR
  if ENV['OEMBED_FACEBOOK_TOKEN'] && !ENV['OEMBED_FACEBOOK_TOKEN'].to_s.empty?
    c.filter_sensitive_data('A_FAKE_TOKEN_FOR_TESTS') { ENV['OEMBED_FACEBOOK_TOKEN'] }
    c.filter_sensitive_data('A_FAKE_TOKEN_FOR_TESTS') { ::CGI.escape(ENV['OEMBED_FACEBOOK_TOKEN']) }
  else
    # If the developer doesn't have an OEMBED_FACEBOOK_TOKEN set
    # use a fake one that will match data in the vcr cassettes.
    ENV['OEMBED_FACEBOOK_TOKEN'] = 'A_FAKE_TOKEN_FOR_TESTS'
  end
end

require 'webmock/rspec'
require 'coveralls'
Coveralls.wear!

require 'support/shared_examples_for_providers'

require File.dirname(__FILE__) + '/../lib/oembed'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.tty = true
  config.color = true
  config.example_status_persistence_file_path = '.rspec-status'
  config.filter_run_including :focus => true unless ENV['RUN_ALL_TESTS']
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    OEmbed::Formatter::JSON.reset_backend
    OEmbed::Formatter::XML.reset_backend
  end
end

def use_custom_vcr_casette(casette_name)
  before(:all) { VCR.insert_cassette(casette_name) }
  after(:all) { VCR.eject_cassette }
end

module OEmbedSpecHelper
  EXAMPLE = YAML.load_file(File.expand_path(File.join(__FILE__, '../spec_helper_examples.yml'))) unless defined?(EXAMPLE)

  def example_url(site)
    return "http://fake.com/" if site == :fake
    EXAMPLE[site][:url]
  end

  def all_example_urls(*fallback)
    results = EXAMPLE.values.map{ |v| v[:url] }

    # By default don't return example_urls that won't be recognized by
    # the included default providers
    results.delete(example_url(:google_video))

    # If requested, return URLs that should work with various fallback providers
    fallback.each do |f|
      case f
      when OEmbed::Providers::OohEmbed
        results << example_url(:google_video)
      end
    end

    results
  end

  def example_body(site)
    EXAMPLE[site][:body]
  end

  def valid_response(format)
    case format.to_s
    when 'object'
      {
        "type" => "photo",
        "version" => "1.0",
        "fields" => "hello",
        "__id__" => 1234
      }
    when 'json'
      <<-JSON.strip
        {
          "type": "photo",
          "version": "1.0",
          "fields": "hello",
          "__id__": 1234
        }
      JSON
    when 'xml'
      <<-XML.strip
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <oembed>
        	<type>photo</type>
        	<version>1.0</version>
        	<fields>hello</fields>
        	<__id__>1234</__id__>
        </oembed>
      XML
    end
  end

  def invalid_response(case_name, format)
    format = format.to_s
    valid = valid_response(format)
    case case_name.to_s
    when 'unclosed_container'
      case format
      when 'json'
        valid_response(format).gsub(/\}\s*\z/, '')
      when 'xml'
        valid_response(format).gsub(%r{</oembed[^>]*>}, '')
      end
    when 'unclosed_tag'
      case format
      when 'json'
        valid_response(format).gsub('"photo"', '"photo')
      when 'xml'
        valid_response(format).gsub('</type>', '')
      end
    when 'invalid_syntax'
      case format
      when 'json'
        valid_response(format).gsub('"type"', '"type":')
      when 'xml'
        valid_response(format).gsub('type', 'ty><pe')
      end
    end
  end
end
