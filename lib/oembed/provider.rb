require 'cgi'
require 'oembed/http_helper'

module OEmbed
  # An OEmbed::Provider has information about an individual oEmbed enpoint.
  class Provider
    include OEmbed::HttpHelper

    # The String that is the http URI of the Provider's oEmbed endpoint.
    # This URL may also contain a {{format}} portion. In actual requests to
    # this Provider, this string will be replaced with a string representing
    # the request format (e.g. "json").
    attr_accessor :endpoint

    # The name of the default format
    # for all request to this Provider (e.g. 'json').
    attr_accessor :format

    # An Array of all URL schemes supported by this Provider.
    attr_accessor :urls

    # Construct a new OEmbed::Provider instance,
    # pointing at a specific oEmbed endpoint.
    #
    # The endpoint should be a String representing
    # the http URI of the Provider's oEmbed endpoint.
    # The endpoint String may also contain a {format} portion.
    # In actual requests to this Provider, this string will be replaced
    # with a String representing the request format (e.g. "json").
    #
    # If give, the format should be the name of the default format
    # for all request to this Provider (e.g. 'json').
    # Defaults to OEmbed::Formatter.default
    #
    # For example:
    #   # If requests should be sent to:
    #   # "http://my.service.com/oembed?format=#{OEmbed::Formatter.default}"
    #   provider = OEmbed::Provider.new("http://my.service.com/oembed")
    #
    #   # If requests should be sent to:
    #   # "http://my.service.com/oembed.xml"
    #   provider = OEmbed::Provider.new(
    #     "http://my.service.com/oembed.{format}", :xml
    #   )
    def initialize(endpoint, format = OEmbed::Formatter.default)
      # rubocop:disable Style/RescueModifier
      endpoint_uri = URI.parse(endpoint.gsub(/[\{\}]/, '')) rescue nil
      # rubocop:enable Style/RescueModifier
      raise(
        ArgumentError,
        "The given endpoint isn't a valid http(s) URI: #{endpoint}"
      ) unless endpoint_uri.is_a?(URI::HTTP)

      @endpoint = endpoint
      @urls = []
      @format = format
    end

    # Adds the given url scheme to this Provider instance.
    # The url scheme can be either a String, containing wildcards specified
    # with an asterisk, (see http://oembed.com/#section2.1 for details),
    # or a Regexp.
    #
    # For example:
    #   @provider << "http://my.service.com/video/*"
    #   @provider << "http://*.service.com/photo/*/slideshow"
    #   @provider << %r{^http://my.service.com/((help)|(faq))/\d+[#\?].*}
    def <<(url)
      unless url.is_a?(Regexp)
        _full, scheme, domain, path = *url.match(%r{([^:]*)://?([^/?]*)(.*)})
        domain = Regexp.escape(domain)
        domain.gsub!('\\*', '(.*?)')
        domain.gsub!('(.*?)\\.', '([^\\.]+\\.)?')
        path = Regexp.escape(path).gsub('\\*', '(.*?)')
        url = Regexp.new("^#{Regexp.escape(scheme)}://#{domain}#{path}")
      end
      @urls << url
    end

    # Send a request to the Provider endpoint to get information about the
    # given url and return the appropriate OEmbed::Response.
    #
    # The query parameter should be a Hash of values which will be
    # sent as query parameters in this request to the Provider endpoint. The
    # following special cases apply to the query Hash:
    # :timeout:: specifies the timeout (in seconds) for the http request.
    # :format:: overrides this Provider's default request format.
    # :url:: will be ignored, replaced by the url param.
    # :max_redirects:: number of times this request will follow 3XX redirects
    #                  before throwing an error. Default: 4
    def get(url, query = {})
      query = query.dup
      query[:format] = (query[:format] || @format).to_s
      OEmbed::Response.create_for(
        raw(url, query),
        self,
        url,
        query[:format]
      )
    end

    # Determine whether the given url is supported by this Provider by matching
    # against the Provider's URL schemes.
    def include?(url)
      @urls.empty? || @urls.any? { |u| u =~ url }
    end

    private

    # Given a URL string & an optional hash of query parameters
    # returns the oEmbed endpoint with the correct parameters configured
    # to get details about the given URL.
    def build(url, query = {})
      raise OEmbed::NotFound, url unless include?(url)

      query = query.merge(:url => ::CGI.escape(url))
      query.delete(:timeout)
      query.delete(:max_redirects)

      built_url = endpoint_with_format(query)
      built_url = add_query_string(built_url, query)

      URI.parse(built_url)
    end

    # Given a query hash
    # if this Provider's endpoint contains the string '{format}'
    # remove the :format value from the query hash
    # interpolate that value into the endpoint string
    # and return the resulting interpolated endpoint string.
    def endpoint_with_format(query)
      if endpoint.include?('{format}')
        formatted = endpoint.clone
        formatted['{format}'] = query[:format]
        query.delete(:format)
        formatted
      else
        endpoint
      end
    end

    # Given a URL String and a query Hash
    # append each of the query key/values to the URL
    # and return the resulting string.
    def add_query_string(url, query)
      query_string = url.include?('?') ? '&' : '?'
      query_string += query.inject('') do |memo, (key, value)|
        "#{key}=#{value}&#{memo}"
      end.chop
      url + query_string
    end

    def raw(url, query = {})
      uri = build(url, query)
      http_get(uri, query)
    rescue OEmbed::UnknownFormat
      # raise with format to be backward compatible
      raise OEmbed::UnknownFormat, format
    end
  end
end
