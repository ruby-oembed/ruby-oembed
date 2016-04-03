# Only allow this backend if ActiveSupport::JSON is already loaded
raise(
  LoadError, "ActiveSupport::JSON isn't available. require 'activesupport/json'"
) unless defined?(ActiveSupport::JSON)

module OEmbed
  module Formatter
    module JSON
      module Backends
        # Use the activesupport gem to parse JSON values.
        module ActiveSupportJSON
          # Parses a JSON string or IO and convert it into an object.
          def decode(json)
            ::ActiveSupport::JSON.decode(json)
          end

          def decode_fail_msg
            'The version of ActiveSupport::JSON you have installed' \
              'isn\'t parsing JSON like ruby-oembed expected.'
          end

          def parse_error
            ::ActiveSupport::JSON.parse_error
          end

          public_instance_methods.each { |method| module_function(method) }
        end
      end
    end
  end
end
