module OEmbed
  class Provider
    class NotFound<StandardError;end
    class UnknownFormat<StandardError;end
    
    attr_accessor :format, :name, :url, :urls, :endpoint
    
    def initialize(endpoint, format = :json)
      @endpoint = endpoint
      @urls = []
      @format = :json
    end
    
    def <<(url)
      # TODO: Needs some fixing
      @urls << Regexp.new(url.gsub("*", "(.*?)"))
    end
    
    def raw(url, options = {})
      raise NotFound, "No embeddable content at '#{url}'" unless include?(url)
      query = options.merge({:url => url})
      endpoint = @endpoint.clone
      
      if format_in_url?
        format = endpoint["{format}"] = query[:format] || @format
        query.delete(:format)
      else
        format = query[:format] ||= @format
      end
      
      query_string = "?" + query.inject("") do |memo, (key, value)|
        "#{key}=#{value}&#{memo}"
      end.chop
      
      uri = URI.parse(endpoint)
      
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.get(uri.path + query_string)
      end
      
      case res
      when Net::HTTPNotImplemented
        raise UnknownFormat, "The provider doesn't support the '#{format}' format"
      when Net::HTTPNotFound
        raise NotFound, "No embeddable content at '#{url}'"
      else
        res.body
      end
    end                   
    
    def format_in_url?
      @endpoint.include?("{format}")
    end   
    
    def include?(url)
      # Shouldn't be used until #<< works properly
      # @urls.detect{ |u| u =~ url } 
      true
    end
  end
end