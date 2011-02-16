# Only allow this backend the json gem is already loaded
raise LoadError, "The json library isn't available. require 'json'" unless defined?(JSON)

module OEmbed
  module Formatter
    module JSON
      module Backends
        module JSONGem
          ParseError = ::JSON::ParserError
          extend self

          # Parses a JSON string or IO and convert it into an object.
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
end

# Only allow this backend if it parses JSON strings the way we expect it to
begin
  raise unless OEmbed::Formatter.test_backend(OEmbed::Formatter::JSON::Backends::JSONGem)
rescue
  raise LoadError, "The version of the json library you have installed isn't parsing JSON like ruby-oembed expected."
end