# Unlike other backends, require REXML if it's not already loaded
require 'rexml/document' unless defined?(REXML)

module OEmbed
  module Formatter
    module XML
      module Backends
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
              obj[el.name] = case obj[el.name]
              when nil
                el.text
              when Array
                obj[el.name] << el.text
              else
                [obj[el.name], el.text]
              end
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
  raise unless OEmbed::Formatter::XML::Backends::REXML.decode(OEmbed::Formatter::XML.test_values[0]) == OEmbed::Formatter::XML.test_values[1]
rescue
  raise LoadError
end