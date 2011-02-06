require 'json' unless defined?(JSON)

module OEmbed
  module Formatter
    module Backends
      module JSONGem
        ParseError = ::JSON::ParserError
        extend self

        # Parses a JSON string or IO and convert it into an object
        def decode(json)
          if json.respond_to?(:read)
            json = json.read
          end
          ::JSON.parse(json)
        end
        
      end
    end
  end
end