module OEmbed
  module Formatter
    module JSON
      # Listed in order of preference.
      DECODERS = %w(ActiveSupportJSON JSONGem Yaml)
      
      class << self
        
        # Returns true if there is a valid JSON backend. Otherwise, raises OEmbed::FormatNotSupported
        def supported?
          !!backend
        end
        
        # Parses a JSON string or IO and convert it into an object
        def decode(json)
          backend.decode(json)
        end
        
        def backend
          set_default_backend unless defined?(@backend)
          raise OEmbed::FormatNotSupported, :json unless defined?(@backend)
          @backend
        end

        def backend=(name)
          if name.is_a?(Module)
            @backend = name
          else
            require "oembed/formatter/json/backends/#{name.to_s.downcase}"
            @backend = OEmbed::Formatter::JSON::Backends::const_get(name)
          end
          @parse_error = @backend::ParseError
        end
        
        def with_backend(name)
          old_backend, self.backend = backend, name
          yield
        ensure
          self.backend = old_backend
        end

        def set_default_backend
          DECODERS.find do |name|
            begin
              self.backend = name
              true
            rescue LoadError
              # Try next decoder.
              false
            end
          end
        end
        
        # Returns a pair of values. The first is a JSON string. The second is the Object
        # we expect to get back after parsing.
        def test_values
          vals = []
          vals << <<-JSON
          {"string":"test", "int":42,"html":"<i>Cool's</i>\\n the \\"word\\"\\u0021", "array":[1,"two"]}
          JSON
          vals << {
            "string"=>"test",
            "int"=>42,
            "html"=>"<i>Cool's</i>\n the \"word\"!",
            "array"=>[1,"two"],
          }
          vals
        end
        
      end
      
    end # JSON
  end
end