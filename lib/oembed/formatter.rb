require 'oembed/formatter/json'
require 'oembed/formatter/xml'

module OEmbed
  # Takes the raw response from an oEmbed server and turns it into a nice Hash of data.
  module Formatter
    
    class << self
      # @return [String] the default format for OEmbed::Provider requests.
      def default
        # Listed in order of preference.
        %w{json xml}.detect { |type| supported?(type) rescue false }
      end
      
      # Is the given response format supported?
      # @param [String, Symbol] format the name of the format we want to know about (e.g. 'json')
      # @return [Boolean] true if there is a valid backend for the given type.
      # @raise [OEmbed::FormatNotSupported] if the given type is not supported.
      def supported?(format)
        case format.to_s
        when 'json'
          JSON.supported?
        when 'xml'
          XML.supported?
        else
          raise OEmbed::FormatNotSupported, format
        end
      end

      # Convert the given value into a nice Hash of values
      # @param [String, Symbol] format the name of the response format (e.g. 'json')
      # @param [String, IO] value the response form an oEmbed server.
      # @return [Hash] the values extracted from the parsed value.
      # @raise [OEmbed::FormatNotSupported] if the given type is not supported.
      # @raise [OEmbed::ParseError] if there was an error parsing given value.
      def decode(format, value)
        supported?(format)
        
        case format.to_s
        when 'json'
          begin
            JSON.decode(value)
          rescue JSON.backend::ParseError
            raise OEmbed::ParseError, $!.message
          end
        when 'xml'
          begin
            XML.decode(value)
          rescue XML.backend::ParseError
            raise OEmbed::ParseError, $!.message
          end
        end
      end
    end
    
  end
end
