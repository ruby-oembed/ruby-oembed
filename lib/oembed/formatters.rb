module OEmbed
  class Formatters
    FORMATS = Hash.new { |_, format| raise OEmbed::FormatNotSupported, format }

    # Load XML
    begin
      require 'xmlsimple'
      FORMATS[:xml] = proc { |r| XmlSimple.xml_in(r, 'ForceArray' => false)}
    rescue LoadError
    end

    # Load JSON
    begin
      require 'json'
      FORMATS[:json] = proc { |r| ::JSON.load(r) }
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
