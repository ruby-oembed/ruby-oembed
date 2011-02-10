# Only allow this backend the json gem is already loaded
raise LoadError unless defined?(JSON)

module OEmbed
  module Formatter
    module JSON
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
end

# Only allow this backend if it parses JSON strings the way we expect it to
begin
 raise unless OEmbed::Formatter::JSON::Backends::JSONGem.decode(OEmbed::Formatter::JSON.test_values[0]) == OEmbed::Formatter::JSON.test_values[1]
rescue
  raise LoadError
end