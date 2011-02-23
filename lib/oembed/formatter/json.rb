module OEmbed
  module Formatter
    # Handles parsing JSON values using the best available backend.
    module JSON
      # A Array of all available backends, listed in order of preference.
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
        
        # Returns the current JSON backend.
        def backend
          set_default_backend unless defined?(@backend)
          raise OEmbed::FormatNotSupported, :json unless defined?(@backend)
          @backend
        end

        def backend=(name)
          if name.is_a?(Module)
            @backend = name
          else
            already_required = false
            begin 
              already_required = OEmbed::Formatter::JSON::Backends.const_defined?(name, false)
            rescue ArgumentError # we're dealing with ruby < 1.9 where const_defined? only takes 1 argument, but behaves the way we want it to.
              already_required = OEmbed::Formatter::JSON::Backends.const_defined?(name)
            rescue NameError # no backends have been loaded yet
              already_required = false
            end
            
            require "oembed/formatter/json/backends/#{name.to_s.downcase}" unless already_required
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
        
      end
      
    end # JSON
  end
end