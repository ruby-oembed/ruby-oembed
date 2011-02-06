module OEmbed
  module Formatter
    module XML
      # Listed in order of preference.
      DECODERS = %w(XmlSimple)
      
      class << self
        
        # Returns true if there is a valid XML backend. Otherwise, raises OEmbed::FormatNotSupported
        def supported?
          !!backend
        end
        
        # Parses an XML string or IO and convert it into an object
        def decode(xml)
          backend.decode(xml)
        end
        
        def backend
          set_default_backend unless defined?(@backend)
          raise OEmbed::FormatNotSupported, :xml unless defined?(@backend)
          @backend
        end
        
        def backend=(name)
          if name.is_a?(Module)
            @backend = name
          else
            require "oembed/formatter/xml/backends/#{name.to_s.downcase}"
            @backend = OEmbed::Formatter::XML::Backends::const_get(name)
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
      
    end # XML
  end
end