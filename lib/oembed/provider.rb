module OEmbed
  class Provider
    attr_accessor :format, :name, :url, :urls, :endpoint

    def initialize(endpoint, format = OEmbed::Formatters::DEFAULT)
      @endpoint = endpoint
      @urls = []
      # Try to use the best available format
      @format = OEmbed::Formatters.verify?(format)
    end

    def <<(url)
      if url.is_a? Regexp
        @urls << url
        return
      end
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
      
      found = false
      max_redirects = 4
      until found
        host, port = uri.host, uri.port if uri.host && uri.port
        res = Net::HTTP.start(uri.host, uri.port) {|http|  http.get(uri.request_uri) }
        res.header['location'] ? uri = URI.parse(res.header['location']) : found = true
        if max_redirects == 0
            found = true
        else
            max_redirects = max_redirects - 1
        end
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
