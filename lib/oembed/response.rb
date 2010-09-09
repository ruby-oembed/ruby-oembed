module OEmbed
  class Response
    METHODS = [:define_methods!, :provider, :field, :fields]
    attr_reader :fields, :provider, :format

    def self.create_for(raw, provider, format = :json)
      fields = OEmbed::Formatters.convert(format, raw)

      resp_type = case fields['type']
        when 'photo' then OEmbed::Response::Photo
        when 'video' then OEmbed::Response::Video
        when 'link'  then OEmbed::Response::Link
        when 'rich'  then OEmbed::Response::Rich
        else              self
      end

      resp_type.new(fields, provider)
    end

    def initialize(fields, provider)
      @fields = fields
      @provider = provider
      define_methods!
    end

    def field(m)
      @fields[m.to_s]
    end

    def video?
      is_a?(OEmbed::Response::Video)
    end

    def photo?
      is_a?(OEmbed::Response::Photo)
    end

    def link?
      is_a?(OEmbed::Response::Link)
    end

    def rich?
      is_a?(OEmbed::Response::Rich)
    end

    private

    def define_methods!
      @fields.keys.each do |key|
        next if METHODS.include?(key.to_sym) || key[0,2]=="__" || key[-1]==??
        class << self
          self
        end.send(:define_method, key) do
          @fields[key]
        end
      end
    end
  end
end
