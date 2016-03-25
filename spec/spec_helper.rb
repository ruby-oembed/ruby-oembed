require 'rubygems'
require 'vcr'

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
      {
        'type' => 'photo',
        'version' => '1.0',
        'fields' => 'hello',
        '__id__' => 1234
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
