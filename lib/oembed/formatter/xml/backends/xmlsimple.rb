# Only allow this backend the xml-simple gem is already loaded
raise LoadError unless defined?(XmlSimple)

module OEmbed
  module Formatter
    module XML
      module Backends
        module XmlSimple
          ParseError = ::ArgumentError
          extend self

          # Parses an XML string or IO and convert it into an object
          def decode(xml)
            if !xml.respond_to?(:read)
              xml = StringIO.new(xml)
            end
            ::XmlSimple.xml_in(xml, 'ForceArray'=>false)    
          rescue
            case $!
            when ::ArgumentError
              raise $!
            else
              raise ::ArgumentError, "Couldn't parse the given document."
            end  
          end
        
        end
      end
    end
  end
end

# Only allow this backend if it parses XML strings the way we expect it to
begin
 raise unless OEmbed::Formatter::XML::Backends::XmlSimple.decode(OEmbed::Formatter::XML.test_values[0]) == OEmbed::Formatter::XML.test_values[1]
rescue
  raise LoadError
end