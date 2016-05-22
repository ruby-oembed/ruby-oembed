require 'rubygems'

require 'vcr'
VCR.config do |c|
  c.default_cassette_options = { :record => :new_episodes }
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :fakeweb
end

require 'coveralls'
Coveralls.wear!

require File.dirname(__FILE__) + '/../lib/oembed'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.tty = true
  config.color = true
end

EXAMPLES = Hash.new do |hash, key|
  raise(
    ArgumentError,
    "No site exists for the key #{key.inspect} in spec_helper_examples.yml"
  ) unless hash.include?(key)
end.merge(
  YAML.load_file(
    File.expand_path(File.join(__FILE__, '../spec_helper_examples.yml'))
  )
)
EXAMPLE_URLS = EXAMPLES.map do |k, v|
  case k
  when :google_video, :qik, :skitch
    nil
  else
    v[:url]
  end
end.compact

# Helper methods to be used with our rspec tests
module OEmbedSpecHelper
  def all_examples
    EXAMPLES
  end

  def example_url(site)
    return 'http://fake.com/' if site == :fake
    all_examples[site][:url]
  end

  def example_body(site)
    all_examples[site][:body]
  end

  def valid_response(format)
    case format.to_s
    when 'object'
      valid_object_response
    when 'json'
      valid_json_response
    when 'xml'
      valid_xml_response
    end
  end

  def invalid_response(case_name, format)
    case case_name.to_s
    when 'unclosed_container'
      invalid_unclosed_container_response(format)
    when 'unclosed_tag'
      invalid_unclosed_tag_response(format)
    when 'invalid_syntax'
      invalid_syntax_response(format)
    end
  end

  private

  def valid_object_response
    {
      'type' => 'photo',
      'version' => '1.0',
      'fields' => 'hello',
      '__id__' => 1234
    }
  end

  def valid_json_response
    <<-JSON.strip
      {
        "type": "photo",
        "version": "1.0",
        "fields": "hello",
        "__id__": 1234
      }
    JSON
  end

  def valid_xml_response
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

  def invalid_unclosed_container_response(format)
    case format.to_s
    when 'json'
      valid_response(format).gsub(/\}\s*\z/, '')
    when 'xml'
      valid_response(format).gsub(%r{</oembed[^>]*>}, '')
    end
  end

  def invalid_unclosed_tag_response(format)
    case format.to_s
    when 'json'
      valid_response(format).gsub('"photo"', '"photo')
    when 'xml'
      valid_response(format).gsub('</type>', '')
    end
  end

  def invalid_syntax_response(format)
    case format.to_s
    when 'json'
      valid_response(format).gsub('"type"', '"type":')
    when 'xml'
      valid_response(format).gsub('type', 'ty><pe')
    end
  end
end
