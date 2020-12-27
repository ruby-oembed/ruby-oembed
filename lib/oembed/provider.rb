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

    # The name of the default format for all request to this Provider (e.g. 'json').
    attr_accessor :format

    # An Array of all URL schemes supported by this Provider.
    attr_accessor :urls

    # The human-readable name of the Provider.
    #
    # @deprecated *Note*: This accessor currently isn't used anywhere in the codebase.
    attr_accessor :name

    # @deprecated *Note*: Added in a fork of the gem, a while back. I really would like
    # to get rid of it, though. --Marcos
    attr_accessor :url


    # Construct a new OEmbed::Provider instance, pointing at a specific oEmbed
    # endpoint.
    #
    # The endpoint should be a String representing the http URI of the Provider's
    # oEmbed endpoint. The endpoint String may also contain a {format} portion.
    # In actual requests to this Provider, this string will be replaced with a String
    # representing the request format (e.g. "json").
    #
    # The `format:` option should be the name of the default format for all request
    # to this Provider (e.g. 'json'). Defaults to OEmbed::Formatter.default
    #
    # # @deprecated *Note*: The `positional_format` is deprecated. Please used the named argument instead.
    #
    # The `required_query_params:` option should be a Hash
    # representing query params that will be appended to the endpoint on each request
    # and the optional name of an environment variable (i.e. ENV) whose value will be used
    #
    # For example:
    #   # If requests should be sent to:
    #   # "http://my.service.com/oembed?format=#{OEmbed::Formatter.default}"
    #   @provider = OEmbed::Provider.new("http://my.service.com/oembed")
    #
    #   # If requests should be sent to:
    #   # "http://my.service.com/oembed.xml"
    #   @xml_provider = OEmbed::Provider.new("http://my.service.com/oembed.{format}", format: :xml)
    #
    #   # If the endpoint requires an `access_token` be specified:
    #   @provider_with_auth = OEmbed::Provider.new("http://my.service.com/oembed", required_query_params: { access_token: 'MY_SERVICE_ACCESS_TOKEN' })
    #   # You can optionally override the value from `ENV['MY_SERVICE_ACCESS_TOKEN']`
    #   @provider_with_auth.access_token = @my_access_token
    def initialize(endpoint, positional_format = OEmbed::Formatter.default, format: nil, required_query_params: {})
      endpoint_uri = URI.parse(endpoint.gsub(/[\{\}]/,'')) rescue nil
      raise ArgumentError, "The given endpoint isn't a valid http(s) URI: #{endpoint.to_s}" unless endpoint_uri.is_a?(URI::HTTP)

      @required_query_params = {}
      required_query_params.each do |param, default_env_var|
        param = param.to_sym
        @required_query_params[param] = nil
        set_required_query_params(param, ENV[default_env_var]) if default_env_var

        # Define a getter and a setter for each required_query_param
        define_singleton_method("#{param}") { @required_query_params[param] } unless respond_to?("#{param}")
        define_singleton_method("#{param}=") { |val| set_required_query_params(param, val) } unless respond_to?("#{param}=")
      end
      required_query_params_set?(reset_cache: true)

      @endpoint = endpoint
      @urls = []
      @format = format || positional_format
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
      if !url.is_a?(Regexp)
        full, scheme, domain, path = *url.match(%r{([^:]*)://?([^/?]*)(.*)})
        domain = Regexp.escape(domain).gsub("\\*", "(.*?)").gsub("(.*?)\\.", "([^\\.]+\\.)?")
        path = Regexp.escape(path).gsub("\\*", "(.*?)")
        url = Regexp.new("^#{Regexp.escape(scheme)}://#{domain}#{path}")
      end
      @urls << url
    end

    # Given the name of a required_query_param and a value
    # store that value internally, so that it can be sent along
    # with requests to this provider's endpoint.
    # Raises an ArgumentError if the given param is not listed with required_query_params
    # during instantiation.
    def set_required_query_params(param, val)
      raise ArgumentError.new("This provider does NOT have a required_query_param named #{param.inspect}") unless @required_query_params.has_key?(param)

      @required_query_params[param] = val.nil? ? nil : ::CGI.escape(val.to_s)

      required_query_params_set?(reset_cache: true)

      @required_query_params[param]
    end

    # Returns true if all of this provider's required_query_params have a value
    def required_query_params_set?(reset_cache: false)
      return @all_required_query_params_set unless reset_cache || @all_required_query_params_set.nil?

      @all_required_query_params_set = !@required_query_params.values.include?(nil)
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
    # :max_redirects:: the number of times this request will follow 3XX redirects before throwing an error. Default: 4
    def get(url, query = {})
      query[:format] ||= @format
      OEmbed::Response.create_for(raw(url, query), self, url, query[:format].to_s)
    end

    # Determine whether the given url is supported by this Provider by matching
    # against the Provider's URL schemes.
    # It will always return false of a provider has required_query_params that are not set.
    def include?(url)
      return false unless required_query_params_set?
      @urls.empty? || !!@urls.detect{ |u| u =~ url }
    end

    # @deprecated *Note*: This method will be made private in the future.
    def build(url, query = {})
      raise OEmbed::NotFound, url unless include?(url)

      query.delete(:timeout)
      query.delete(:max_redirects)

      query = query.merge(@required_query_params)
      query = query.merge({:url => ::CGI.escape(url)})

      # TODO: move this code exclusively into the get method, once build is private.
      this_format = (query[:format] ||= @format.to_s).to_s

      endpoint = @endpoint.clone

      if endpoint.include?("{format}")
        endpoint["{format}"] = this_format
        query.delete(:format)
      end

      base = endpoint.include?('?') ? '&' : '?'
      query = base + query.inject("") do |memo, (key, value)|
        "#{key}=#{value}&#{memo}"
      end.chop

      URI.parse(endpoint + query).instance_eval do
        @format = this_format
        def format
          @format
        end
        self
      end
    end

    # @deprecated *Note*: This method will be made private in the future.
    def raw(url, query = {})
      uri = build(url, query)
      http_get(uri, query)
    rescue OEmbed::UnknownFormat
      # raise with format to be backward compatible
      raise OEmbed::UnknownFormat, format
    end
  end
end
