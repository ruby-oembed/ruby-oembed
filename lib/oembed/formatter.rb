require 'oembed/formatter/base'
require 'oembed/formatter/json'
require 'oembed/formatter/xml'

module OEmbed
  # Takes the raw response from an oEmbed server
  # and turns it into a nice Hash of data.
  module Formatter
    class << self
      # Returns the default format for OEmbed::Provider requests as a String.
      def default
        # Listed in order of preference.
        %w(json xml).detect do |type|
          begin
            supported?(type)
          rescue
            false
          end
        end
      end

      # Given the name of a format we want to know about (e.g. 'json'), returns
      # true if there is a valid backend. If there is no backend, raises
      # OEmbed::FormatNotSupported.
      def supported?(format)
        formater_class(format).supported?
      end

      # Convert the given value into a nice Hash of values. The format should
      # be the name of the response format (e.g. 'json'). The value should be
      # a String or IO containing the response from an oEmbed server.
      #
      # For example:
      #   value = '{"version": "1.0", "type": "link", "title": "Cool Article"}'
      #   OEmbed::Formatter.decode('json', value)
      #   #=> {"version": "1.0", "type": "link", "title": "Cool Article"}
      def decode(format, value)
        supported?(format)

        begin
          formater_class(format).decode(value)
        rescue formater_class(format).backend.parse_error
          raise OEmbed::ParseError, $!.message
        rescue
          raise OEmbed::ParseError, "#{$!.class}: #{$!.message}"
        end
      end

      private

      # Returns the OEmbed::Formatter sub-class for the given format string
      def formater_class(format)
        case format.to_s
        when 'json'
          JSON
        when 'xml'
          XML
        else
          fail OEmbed::FormatNotSupported, format
        end
      end
    end # self
  end
end
