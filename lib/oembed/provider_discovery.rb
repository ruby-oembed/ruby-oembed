require 'oembed/http_helper'

module OEmbed
  # Uses oEmbed Discover to generate a new Provider instance
  # about a URL for which a Provider didn't previously exist.
  # See: http://oembed.com/#section4
  class ProviderDiscovery
    class << self
      include OEmbed::HttpHelper

      # Discover the Provider for the given url,
      # then call Provider#get on that provider.
      #
      # The query parameter will be passed
      # to both discover_provider and Provider#get
      def get(url, query = {})
        provider = discover_provider(url, query)
        provider.get(url, query)
      end

      # Returns a new Provider instance based on information
      # from oEmbed discovery performed on the given url.
      #
      # The options Hash recognizes the following keys:
      # :format:: If given only discover endpoints for the given format.
      #           If not format is given, use the first available format found.
      # :timeout:: specifies the timeout (in seconds) for the http request.
      # :max_redirects:: number of times this request will follow 3XX redirects
      #                  before throwing an error. Default: 4
      def discover_provider(url, options = {})
        uri = URI.parse(url)

        res = http_get(uri, options)
        format = options[:format]

        if format.nil? || format == :json
          begin
            provider_endpoint ||= \
              %r{<link[^>]*href=['"]*([^\s'"]+)['"]*[^>]*application/json\+oembed[^>]*>}.match(res)[1]
          rescue
          end

          begin
            provider_endpoint ||= \
              %r{<link[^>]*application/json\+oembed[^>]*href=['"]*([^\s'"]+)['"]*[^>]*>}.match(res)[1]
          rescue
          end

          format ||= :json if provider_endpoint
        end

        if format.nil? || format == :xml
          # {The specification}[http://oembed.com/#section4] says
          # XML discovery should have type="text/xml+oembed"
          # but some providers use type="application/xml+oembed"
          begin
            provider_endpoint ||= \
              %r{<link[^>]*href=['"]*([^\s'"]+)['"]*[^>]*(application|text)/xml\+oembed[^>]*>}.match(res)[1]
          rescue
          end

          begin
          provider_endpoint ||= \
            %r{<link[^>]*(application|text)\/xml\+oembed[^>]*href=['"]*([^\s'"]+)['"]*[^>]*>}.match(res)[2]
          rescue
          end

          format ||= :xml if provider_endpoint
        end

        begin
          provider_endpoint = URI.parse(provider_endpoint)
          provider_endpoint.query = nil
          provider_endpoint = provider_endpoint.to_s
        rescue URI::Error
          raise OEmbed::NotFound, url
        end

        Provider.new(provider_endpoint, format || OEmbed::Formatter.default)
      end
    end
  end
end
