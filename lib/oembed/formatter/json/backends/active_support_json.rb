require 'active_support/json/decoding' unless defined?(ActiveSupport::JSON)

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