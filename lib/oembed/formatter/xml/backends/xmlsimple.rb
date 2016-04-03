# Only allow this backend the xml-simple gem is already loaded
raise(
  ::LoadError, "The xml-simple library isn't available. require 'xmlsimple'"
) unless defined?(XmlSimple)

module OEmbed
  module Formatter
    module XML
      module Backends
        # Use the xml-simple gem to parse XML values.
        module XmlSimple
          # Parses an XML string or IO and convert it into an object.
          def decode(xml)
            xml = StringIO.new(xml) unless xml.respond_to?(:read)
            ::XmlSimple.xml_in(xml, 'ForceArray' => false)
          end

          def decode_fail_msg
            'The version of the xml-simple library you have installed ' \
              'isn\'t parsing XML like ruby-oembed expected.'
          end

          def parse_error
            ::ArgumentError
          end

          public_instance_methods.each { |method| module_function(method) }
        end
      end
    end
  end
end
