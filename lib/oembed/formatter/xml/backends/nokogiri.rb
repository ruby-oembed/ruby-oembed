# Only allow this backend the nokogiri gem is already loaded
fail ::LoadError, "The nokogiri library isn't available. require 'nokogiri'" unless defined?(Nokogiri)

module OEmbed
  module Formatter
    module XML
      module Backends
        # Use the nokogiri gem to parse XML values.
        module Nokogiri
          extend self

          # Parses an XML string or IO and convert it into an object.
          def decode(xml)
            obj = {}
            doc = ::Nokogiri::XML(xml, &:strict)
            doc.root.elements.each do |el|
              obj[el.name] = el.text
            end
            obj
          rescue
            case $ERROR_INFO
            when parse_error
              raise $ERROR_INFO
            else
              raise parse_error, "Couldn't parse the given document."
            end
          end

          def decode_fail_msg
            "The version of the nokogiri library you have installed isn't parsing XML like ruby-oembed expected."
          end

          def parse_error
            ::Nokogiri::XML::SyntaxError
          end
        end
      end
    end
  end
end
