module OEmbed
  class Response
    METHODS = [:initialize, :provider, :field, :fields, :__send__, :__id__]
    attr_reader :fields, :provider
    
    def initialize(json, provider)
      @fields = JSON.load(json)
      @provider = provider
      define_methods!
    end
    
    def field(m)
      @fields[m.to_s]
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