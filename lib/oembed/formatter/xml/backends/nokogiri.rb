# Only allow this backend the nokogiri gem is already loaded
raise(
  ::LoadError, 'The nokogiri library isn\'t available. require \'nokogiri\''
) unless defined?(Nokogiri)

module OEmbed
  module Formatter
    module XML
      module Backends
        # Use the nokogiri gem to parse XML values.
        module Nokogiri
          # Parses an XML string or IO and convert it into an object.
          def decode(xml)
            obj = {}
            doc = ::Nokogiri::XML(xml, &:strict)
            doc.root.elements.each do |el|
              obj[el.name] = el.text
            end
            obj
          end

          def decode_fail_msg
            'The version of the nokogiri library you have installed' \
              'isn\'t parsing XML like ruby-oembed expected.'
          end

          def parse_error
            ::Nokogiri::XML::SyntaxError
          end

          public_instance_methods.each { |method| module_function(method) }
        end
      end
    end
  end
end
