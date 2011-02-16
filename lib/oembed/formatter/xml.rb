module OEmbed
  module Formatter
    # Handles parsing XML values using the best available backend.
    module XML
      # A Array of all available backends, listed in order of preference.
      DECODERS = %w(XmlSimple REXML)
      
      class << self
        
        # Returns true if there is a valid XML backend. Otherwise, raises OEmbed::FormatNotSupported
        def supported?
          !!backend
        end
        
        # Parses an XML string or IO and convert it into an object
        def decode(xml)
          backend.decode(xml)
        end
        
        # Returns the current XML backend.
        def backend
          set_default_backend unless defined?(@backend)
          raise OEmbed::FormatNotSupported, :xml unless defined?(@backend)
          @backend
        end
        
        # Sets the current XML backend. Raises a LoadError if the given
        # backend cannot be loaded
        #   OEmbed::Formatter::XML.backend = 'REXML'
        def backend=(name)
          if name.is_a?(Module)
            @backend = name
          else
            already_required = OEmbed::Formatter::XML::Backends.const_defined?(name) rescue nil
            require "oembed/formatter/xml/backends/#{name.to_s.downcase}" unless already_required
            @backend = OEmbed::Formatter::XML::Backends.const_get(name)
          end
          @parse_error = @backend::ParseError
        end
        
        # Perform a set of operations using a backend other than the current one.
        #   OEmbed::Formatter::XML.with_backend('XmlSimple') do
        #     OEmbed::Formatter::XML.decode(xml_value)
        #   end
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