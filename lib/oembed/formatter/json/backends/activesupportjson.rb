# Only allow this backend if ActiveSupport::JSON is already loaded
raise LoadError, "ActiveSupport::JSON isn't available. require 'activesupport/json'" unless defined?(ActiveSupport::JSON)

module OEmbed
  module Formatter
    module JSON
      module Backends
        module ActiveSupportJSON
          ParseError = ::ActiveSupport::JSON.parse_error
          extend self

          # Parses a JSON string or IO and convert it into an object.
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
  raise unless OEmbed::Formatter.test_backend(OEmbed::Formatter::JSON::Backends::ActiveSupportJSON)
rescue
  raise LoadError, "The version of ActiveSupport::JSON you have installed isn't parsing JSON like ruby-oembed expected."
end