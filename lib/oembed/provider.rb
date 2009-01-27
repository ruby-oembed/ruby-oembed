module OEmbed
  class Provider
    attr_accessor :format, :name, :url, :urls, :endpoint
    
    def initialize(endpoint, format = nil)
      @endpoint = endpoint
      @urls = []
      # Try to use the best available format
      available_formats = [
        [:json, lambda {
          begin
            JSON.respond_to?(:load)
          rescue NameError
            false
          end
        }],
        [:xml, lambda {
          begin
            XmlSimple.respond_to?(:xml_in)
          rescue NameError
            false
          end
        }],
      ]
      if format && to_try = available_formats.assoc(format)
        available_formats.delete(to_try)
        @format = format if to_try[1].call
      end
      available_formats.each do |format, to_try|
        break unless @format.nil?
        @format = format if to_try.call
      end
    end
    
    def <<(url)
      full, scheme, domain, path = *url.match(%r{([^:]*)://?([^/?]*)(.*)})
      domain = Regexp.escape(domain).gsub("\\*", "(.*?)").gsub("(.*?)\\.", "([^\\.]+\\.)?")
      path = Regexp.escape(path).gsub("\\*", "(.*?)")
      @urls << Regexp.new("^#{Regexp.escape(scheme)}://#{domain}#{path}")
    end
    
    def build(url, options = {})
      raise OEmbed::NotFound, url unless include?(url)
      query = options.merge({:url => url})
      endpoint = @endpoint.clone
      
      if format_in_url?
        format = endpoint["{format}"] = (query[:format] || @format).to_s
        query.delete(:format)
      else
        format = query[:format] ||= @format
      end
      
      query_string = "?" + query.inject("") do |memo, (key, value)|
        "#{key}=#{value}&#{memo}"
      end.chop
      
      URI.parse(endpoint + query_string).instance_eval do
        @format = format; def format; @format; end
        self
      end      
    end
    
    def raw(url, options = {})
      uri = build(url, options)
      
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.get(uri.request_uri)
      end
      
      case res
      when Net::HTTPNotImplemented
        raise OEmbed::UnknownFormat, uri.format
      when Net::HTTPNotFound
        raise OEmbed::NotFound, url
      when Net::HTTPOK
        res.body
      else
        raise OEmbed::UnknownResponse, res.code
      end
    end
    
    def get(url, options = {})
      options[:format] ||= @format if @format
      OEmbed::Response.create_for(raw(url, options), self, options[:format])
    end                   
    
    def format_in_url?
      @endpoint.include?("{format}")
    end   
    
    def include?(url)
      @urls.empty? || !!@urls.detect{ |u| u =~ url } 
    end
  end
end