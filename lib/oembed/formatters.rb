module OEmbed
  class Formatters
    FORMATS = Hash.new { |_, format| raise OEmbed::FormatNotSupported, format }

    # Load XML
    begin
      require 'xmlsimple'
      FORMATS[:xml] = proc do |r|
        begin
          XmlSimple.xml_in(StringIO.new(r), 'ForceArray' => false)
        rescue
          case $!
          when ::ArgumentError
            raise $!
          else
            raise ::ArgumentError, "Couldn't parse the given document."
          end
        end
      end
    rescue LoadError
    end

    # Load JSON
    begin
      require 'json'
      FORMATS[:json] = proc { |r| ::JSON.load(r.to_s) }
    rescue LoadError
    end

    DEFAULT = FORMATS.keys.first

    def self.verify?(type)
      FORMATS[type] && type
    end

    def self.convert(type, value)
      FORMATS[type].call(value)
    end
  end
end
