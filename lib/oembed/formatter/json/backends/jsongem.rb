# Only allow this backend the json gem is already loaded
raise(
  LoadError, "The json library isn't available. require 'json'"
) unless Object.const_defined?('JSON')

module OEmbed
  module Formatter
    module JSON
      module Backends
        # Use the ruby-json gem to parse JSON values.
        module JSONGem
          # Parses a JSON string or IO and convert it into an object.
          def decode(json)
            json = json.read if json.respond_to?(:read)
            ::JSON.parse(json)
          end

          def decode_fail_msg
            'The version of the json library you have installed' \
              'isn\'t parsing JSON like ruby-oembed expected.'
          end

          def parse_error
            ::JSON::ParserError
          end

          public_instance_methods.each { |method| module_function(method) }
        end
      end
    end
  end
end
