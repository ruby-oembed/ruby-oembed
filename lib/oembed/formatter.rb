require 'oembed/formatter/json'
require 'oembed/formatter/xml'

module OEmbed
  module Formatter
    
    class << self
      # Returns a Symbol representing the default format for OEmbed requests.
      def default
        # Listed in order of preference.
        %w{json xml}.detect { |type| supported?(type) rescue false }
      end
      
      # Returns true if there is a valid JSON backend. Otherwise, raises OEmbed::FormatNotSupported
      def supported?(type)
        case type.to_s
        when 'json'
          JSON.supported?
        when 'xml'
          XML.supported?
        else
          raise OEmbed::FormatNotSupported, type
        end
      end

      # Use the specified formatter to parse the given string or IO and convert it into an object
      def decode(type, value)
        case type.to_s
        when 'json'
          JSON.decode(value)
        when 'xml'
          XML.decode(value)
        else
          raise OEmbed::FormatNotSupported, type
        end
      end
    end
    
  end
end
