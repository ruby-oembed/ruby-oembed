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

        provider_endpoint, format = discover_oembed_url(res, format)

        begin
          provider_endpoint = URI.parse(provider_endpoint)
          provider_endpoint.query = nil
          provider_endpoint = provider_endpoint.to_s
        rescue URI::Error
          raise OEmbed::NotFound, url
        end

        Provider.new(provider_endpoint, format || OEmbed::Formatter.default)
      end

      private

      def discover_oembed_url(html, format)
        provider_endpoint = nil

        if format.nil? || format == :json
          provider_endpoint = get_oembed_url_for(
            html,
            %w(application/json+oembed)
          )
          format ||= :json if provider_endpoint
        end

        if !provider_endpoint && format.nil? || format == :xml
          provider_endpoint, format = get_oembed_url_for(
            html,
            %w(application/xml+oembed text/xml+oembed)
          )
          format ||= :xml if provider_endpoint
        end

        [provider_endpoint, format]
      end

      def get_oembed_url_for(html, content_types)
        content_types = content_types.map do |content_type|
          Regexp.escape(content_type)
        end

        found_url = nil
        {
          :url => %r{href=['"]*([^\s'"]+)['"]},
          :type => %r{(#{content_types.join('|')})}
        }.to_a.permutation.each do |regexps|
          found_url = try_getting_a_url(
            html,
            regexps.map { |_k,v| v },
            regexps.index { |k,_v| k == :url }
          )
          break if found_url
        end
        found_url
      end

      def try_getting_a_url(html, regexps, match_index)
        match = html.match(build_link_url_regexp(regexps))
        match && match[match_index + 1]
      end

      def build_link_url_regexp(regexps)
        regexp_array = [/<link\s/]
        regexp_array += regexps
        regexp_array += [/>/]
        Regexp.new(
          regexp_array.map{|r| r.source}.join("[^>]*")
        )
      end
    end
  end
end
