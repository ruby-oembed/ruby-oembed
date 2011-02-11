# Only allow this backend if ActiveSupport::JSON is already loaded
raise LoadError unless defined?(ActiveSupport::JSON)

module OEmbed
  module Formatter
    module JSON
      module Backends
        module ActiveSupportJSON
          ParseError = ::ActiveSupport::JSON.parse_error
          extend self

          # Parses a JSON string or IO and convert it into an object
          def decode(json)
            ::ActiveSupport::JSON.decode(json)
          end
        
        end
      end
    end
  end
end

# Only allow this backend if it parses JSON strings the way we expect it to
begin
  raise unless OEmbed::Formatter::JSON::Backends::ActiveSupportJSON.decode(OEmbed::Formatter::JSON.test_values[0]) == OEmbed::Formatter::JSON.test_values[1]
rescue
  raise LoadError
end