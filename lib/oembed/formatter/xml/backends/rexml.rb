# Unlike other backends, require REXML if it's not already loaded
require 'rexml/document' unless defined?(REXML)

module OEmbed
  module Formatter
    module XML
      module Backends
        # Use the REXML library, part of the standard library, to parse XML values.
        module REXML
          ParseError = ::REXML::ParseException
          extend self

          # Parses an XML string or IO and convert it into an object
          def decode(xml)
            if !xml.respond_to?(:read)
              xml = StringIO.new(xml)
            end
            obj = {}
            doc = ::REXML::Document.new(xml)
            doc.elements[1].elements.each do |el|
              obj[el.name] = el.text
            end
            obj
          rescue
            case $!
            when ParseError
              raise $!
            else
              raise ParseError, "Couldn't parse the given document."
            end  
          end
        
        end
      end
    end
  end
end

# Only allow this backend if it parses XML strings the way we expect it to
begin
  raise unless OEmbed::Formatter.test_backend(OEmbed::Formatter::XML::Backends::REXML)
rescue
  raise LoadError, "The version of the REXML library you have installed isn't parsing XML like ruby-oembed expected."
end