module OEmbed
  class Response
    METHODS = [:define_methods!, :provider, :field, :fields, :__send__, :__id__]
    attr_reader :fields, :provider
    
    def self.create_for(json, provider)
      fields = JSON.load(json)

      case fields['type']
        when 'photo' : resp_type = OEmbed::Photo
        when 'video' : resp_type = OEmbed::Video
        when 'link'  : resp_type = OEmbed::Link
        when 'rich'  : resp_type = OEmbed::Rich
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
        next if METHODS.include?(key.to_sym)
        class << self
          self
        end.send(:define_method, key) do
          @fields[key]
        end
      end
    end
  end
end