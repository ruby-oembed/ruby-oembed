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
            @backend = OEmbed::Formatter::JSON::Backends::const_get(name) rescue nil
            if @backend.nil?
              require "oembed/formatter/json/backends/#{name.to_s.downcase}"
              @backend = OEmbed::Formatter::JSON::Backends::const_get(name)
            end
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