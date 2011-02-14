module OEmbed
  # An OEmbed::Provider has information about an individual oEmbed enpoint.
  class Provider
    
    # @return [String] the http URI of the Provider's oEmbed endpoint.
    #  The URL may also contain a {{format}} portion. In actual requests to
    #  this Provider, this string will be replaced with a string representing
    #  the request format (e.g. "json").
    attr_accessor :endpoint
    
    # @return [String, Symbol] the name of the default format for all request
    #  to this Provider. (e.g. 'json') 
    attr_accessor :format
    
    # @return [String] the human-readable name of the Provider
    # @deprecated This accessor currently isn't used anywhere in the codebase.
    attr_accessor :name
    
    # @deprecated Added in a fork of the gem, a while back. I really would like
    #  to get rid of it, though. --Marcos
    attr_accessor :url
    
    # @return [Array] an Array of all URL schemes supported by this Provider.
    attr_accessor :urls
    
    

    # Construct a new OEmbed::Provider instance, pointing at a specific oEmbed
    # endpoint.
    # @param [String] endpoint the http URI of the Provider's oEmbed endpoint.
    #  The URL may also contain a {{format}} portion. In actual requests to
    #  this Provider, this string will be replaced with a string representing
    #  the request format (e.g. "json").
    # @param [String, Symbol] format the name of the default format for all request
    #  to this Provider. (e.g. 'json')
    # @example
    #   OEmbed::Provider.new("http://my.service.com/oembed")
    #   OEmbed::Provider.new("http://my.service.com/oembed.{format}", :xml)
    def initialize(endpoint, format = OEmbed::Formatter.default)
      endpoint_uri = URI.parse(endpoint.gsub(/[\{\}]/,'')) rescue nil
      raise ArgumentError, "The given endpoint isn't a valid http(s) URI: #{endpoint.to_s}" unless endpoint_uri.is_a?(URI::HTTP)
      
      @endpoint = endpoint
      @urls = []
      @format = format
    end

    # Adds the given URL scheme to this Provider instance.
    # @param [String, Regexp] The URL scheme can be either a String,
    #  containing wildcards specified with an asterisk, (see
    #  http://oembed.com/#section2.1 for details), or a Regexp.
    # @example
    #   @provider << "http://my.service.com/video/*"
    #   @provider << "*://*.service.com/photo/*/slideshow"
    #   @provider << %r{^http://my.service.com/((help)|(faq))/\d+[#\?].*}
    def <<(url)
      if !url.is_a?(Regexp)
        full, scheme, domain, path = *url.match(%r{([^:]*)://?([^/?]*)(.*)})
        domain = Regexp.escape(domain).gsub("\\*", "(.*?)").gsub("(.*?)\\.", "([^\\.]+\\.)?")
        path = Regexp.escape(path).gsub("\\*", "(.*?)")
        url = Regexp.new("^#{Regexp.escape(scheme)}://#{domain}#{path}")
      end
      @urls << url
    end

    # Send a request to the Provider endpoint to get information about the
    # given URL.
    # @param [String] url the URL about which we want to get information using oEmbed.
    # @param [Hash] query these values will be sent as query parameters in this
    #  request to the Provider endpoint, with the following special cases:
    # @option query [String, Symbol] :format overrides this Provider's default 
    #  request format.
    # @option query [String] :url will be ignored, replaced by the url param.
    # @raise [OEmbed::NotFound] if the given url is not suppoted by this Provider.
    def get(url, query = {})
      query[:format] ||= @format if @format
      OEmbed::Response.create_for(raw(url, query), self, url, query[:format])
    end
    
    # Determine whether this URL is supported by this Provider by matching
    # against the Provider's URL schemes.
    # @param [String] url the URL we want to know whether this Provider supports.
    def include?(url)
      @urls.empty? || !!@urls.detect{ |u| u =~ url }
    end

    # @private
    def build(url, query = {})
      raise OEmbed::NotFound, url unless include?(url)

      query = query.merge({:url => url})
      endpoint = @endpoint.clone

      if @endpoint.include?("{format}")
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

    # @private
    def raw(url, query = {})
      uri = build(url, query)
      
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
      if defined?(::JSON) && $!.is_a?(::JSON::JSONError) || $!.class.to_s =~ /\ANet::/
        raise OEmbed::UnknownResponse, res && res.respond_to?(:code) ? res.code : 'Error'
      else
        raise $!
      end
    end
  end
end
