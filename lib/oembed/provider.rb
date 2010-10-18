module OEmbed
  class Provider
    attr_accessor :format, :name, :url, :urls, :endpoint

    # Returns a new OEmbed::Provider instance. The first argument should be the
    # http URL of the Provider's oEmbed endpoint. The URL may also contain a
    # "{format}" portion. In actual requests to this endpoint, this string will
    # be replaced with a string representing the request format (e.g. "json").
    # The second argument is an  optional Symbol that defines the default format
    # for all oEmbed requests to this Provider.
    #     OEmbed::Provider.new("http://my.service.com/oembed")
    #     OEmbed::Provider.new("http://my.service.com/oembed.{format}", :xml)
    def initialize(endpoint, format = OEmbed::Formatters::DEFAULT)
      endpoint_uri = URI.parse(endpoint.gsub(/[\{\}]/,'')) rescue nil
      raise ArgumentError, "The given endpoint isn't a valid http(s) URI: #{endpoint.to_s}" unless endpoint_uri.is_a?(URI::HTTP)
      
      @endpoint = endpoint
      @urls = []
      # Try to use the best available format
      @format = OEmbed::Formatters.verify?(format)
    end

    # Adds the given URL scheme to a Provider instance. The URL scheme can be either
    # a string containing wildcards specified with an asterisk (see
    # http://oembed.com/#section2.1 for details) or a Regexp.
    #    @provider << "http://my.service.com/video/*"
    #    @provider << "*://*.service.com/photo/*/slideshow"
    #    @provider << %r{^http://my.service.com/((help)|(faq))/\d+[#\?].*}
    def <<(url)
      if !url.is_a?(Regexp)
        full, scheme, domain, path = *url.match(%r{([^:]*)://?([^/?]*)(.*)})
        domain = Regexp.escape(domain).gsub("\\*", "(.*?)").gsub("(.*?)\\.", "([^\\.]+\\.)?")
        path = Regexp.escape(path).gsub("\\*", "(.*?)")
        url = Regexp.new("^#{Regexp.escape(scheme)}://#{domain}#{path}")
      end
      @urls << url
    end

    def build(url, query = {})
      raise OEmbed::NotFound, url unless include?(url)
      query = query.merge({:url => url})
      endpoint = @endpoint.clone

      if format_in_url?
        format = endpoint["{format}"] = (query[:format] || @format).to_s
        query.delete(:format)
      else
        format = query[:format] ||= @format
      end

      query = "?" + query.inject("") do |memo, (key, value)|
        "#{key}=#{value}&#{memo}"
      end.chop

      URI.parse(endpoint + query).instance_eval do
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
        res = Net::HTTP.start(uri.host, uri.port) {|http| http.get(uri.request_uri) }
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
        raise OEmbed::UnknownResponse, res && res.respond_to?(:code) ? res.code : 'Error'
      end
    rescue StandardError
      # Convert known errors into OEmbed::UnknownResponse for easy catching
      # up the line. This is important if given a URL that doesn't support
      # OEmbed. The following are known errors:
      # * Net::* errors like Net::HTTPBadResponse
      # * JSON::JSONError errors like JSON::ParserError
      if $!.is_a?(JSON::JSONError) || $!.class.to_s =~ /\ANet::/
        raise OEmbed::UnknownResponse, res && res.respond_to?(:code) ? res.code : 'Error'
      else
        raise $!
      end
    end

    def get(url, options = {})
      options[:format] ||= @format if @format
      OEmbed::Response.create_for(raw(url, options), self, url, options[:format])
    end

    def format_in_url?
      @endpoint.include?("{format}")
    end

    def include?(url)
      @urls.empty? || !!@urls.detect{ |u| u =~ url }
    end
  end
end
