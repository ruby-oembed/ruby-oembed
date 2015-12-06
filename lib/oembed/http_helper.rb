module OEmbed
  module HttpHelper

    private

    # Given a URI, make an HTTP request
    #
    # The options Hash recognizes the following keys:
    # :timeout:: specifies the timeout (in seconds) for the http request.
    def http_get(uri, options = {})
      found = false
      max_redirects = 4
      until found
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.read_timeout = http.open_timeout = options[:timeout] if options[:timeout]

        methods = if RUBY_VERSION < "2.2"
            %w{scheme userinfo host port registry}
        else
            %w{scheme userinfo host port}
        end
        methods.each { |method| uri.send("#{method}=", nil) }
        req = Net::HTTP::Get.new(uri.to_s)
        req['User-Agent'] = "Mozilla/5.0 (compatible; ruby-oembed/#{OEmbed::VERSION})"
        res = http.request(req)

        #res = Net::HTTP.start(uri.host, uri.port) {|http| http.get(uri.request_uri) }

        res.header['location'] ? uri = URI.parse(res.header['location']) : found = true
        if max_redirects == 0
          found = true
        else
          max_redirects -= 1
        end
      end

      case res
      when Net::HTTPNotImplemented
        raise OEmbed::UnknownFormat
      when Net::HTTPNotFound
        raise OEmbed::NotFound, uri
      when Net::HTTPSuccess
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
