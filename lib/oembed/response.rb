module OEmbed
  class Response
    attr_reader :fields, :provider
    
    def initialize(json, provider)
      @fields = JSON.load(json)
      @provider = provider
      
      @provider.url ||= @fields.delete("provider_url")
      @provider.name ||= @fields.delete("provider_name")     
    end
    
    def field(m)
      @fields[m.to_s]
    end
    
    def method_missing(meth, *args, &blk)
      field(meth) || super
    end
  end
end