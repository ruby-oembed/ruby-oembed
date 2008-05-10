module OEmbed
  class Response
    attr_reader :fields, :provider
    
    def initialize(json, provider)
      @fields = JSON.load(json)
      @provider = provider
    end
    
    def field(m)
      @fields[m.to_s]
    end
    
    def method_missing(meth, *args, &blk)
      field(meth) || super
    end
  end
end