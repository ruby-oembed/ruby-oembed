module OEmbed
  class ProviderDiscovery
    class << self
    def raw(url, options = {})
      provider = discover_provider(url, options)
      provider.raw(url, options)
    end

    def get(url, options = {})
      provider = discover_provider(url, options)
      provider.get(url, options)
    end

    def discover_provider(url, options = {})
      uri = URI.parse(url)

      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.get(uri.request_uri)
      end

      case res
      when Net::HTTPNotFound
        raise OEmbed::NotFound, url
      when Net::HTTPOK
        format = options[:format]

        if format.nil? || format == :json
          provider_endpoint ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/json\+oembed.*>/.match(res.body)
          provider_endpoint ||= /<link.*application\/json\+oembed.*href=['"]*([^\s'"]+)['"]*.*>/.match(res.body)
          format ||= :json if provider_endpoint
        end
        if format.nil? || format == :xml
          provider_endpoint ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/xml\+oembed.*>/.match(res.body)
          provider_endpoint ||= /<link.*application\/xml\+oembed.*href=['"]*([^\s'"]+)['"]*.*>/.match(res.body)
          format ||= :xml if provider_endpoint
        end

        begin
          provider_endpoint = URI.parse(provider_endpoint && provider_endpoint[1])
          provider_endpoint.query = nil
          provider_endpoint = provider_endpoint.to_s
        rescue URI::Error
          raise OEmbed::NotFound, url
        end


        Provider.new(provider_endpoint, format || OEmbed::Formatters::DEFAULT)
      else
        raise OEmbed::UnknownResponse, res.code
      end
    end

    end
  end
end
