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
        
        # Returns a pair of values. The first is an XML string. The second is the Object
        # we expect to get back after parsing.
        def test_values
          vals = []
          vals << <<-XML
          <?xml version="1.0" encoding="utf-8" standalone="yes"?>
          <oembed>
          	<string>test</string>
          	<int>42</int>
          	<html>&lt;i&gt;Cool's&lt;/i&gt;\n the &quot;word&quot;&#x21;</html>
          	<array>1</array>
          	<array>two</array>
          </oembed>
          XML
          vals << {
            "string"=>"test",
            "int"=>"42",
            "html"=>"<i>Cool's</i>\n the \"word\"!",
            "array"=>["1","two"],
          }
          vals
        end
        
      end
      
    end # XML
  end
end