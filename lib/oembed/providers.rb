require 'rubygems'
require 'yaml'

module OEmbed
  # Allows OEmbed to perform tasks across several, registered, Providers
  # at once.
  class Providers
    class << self
      @@urls = {}
      @@fallback = []
      @@to_register = {}
      @@access_token_setters = {}

      # A Hash of all url schemes, where the keys represent schemes supported by
      # all registered Provider instances and values are an Array of Providers
      # that support that scheme.
      def urls
        @@urls
      end

      # Given one ore more Provider instances, register their url schemes for
      # future get calls.
      def register(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            @@urls[url] ||= []
            @@urls[url] << provider
          end
        end
      end

      # Given one ore more Provider instances, un-register their url schemes.
      # Future get calls will not use these Providers.
      def unregister(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            if @@urls[url].is_a?(Array)
              @@urls[url].delete(provider)
              @@urls.delete(url) if @@urls[url].empty?
            end
          end
        end
      end

      # Register all Providers built into this gem.
      # The including_sub_type parameter should be one of the following values:
      # * :aggregators: also register provider aggregator endpoints, like Embedly
      # The access_tokens keys can be one of the following:
      # * :facebook: See https://developers.facebook.com/docs/instagram/oembed#access-tokens
      def register_all(*including_sub_type, access_tokens: {})
        register(*@@to_register[""])
        including_sub_type.each do |sub_type|
          register(*@@to_register[sub_type.to_s])
        end
        set_access_tokens(access_tokens)
      end

      # Unregister all currently-registered Provider instances.
      def unregister_all
        @@urls = {}
        @@fallback = []
      end

      # Takes an array of Provider instances or ProviderDiscovery
      # Use this method to register fallback providers.
      # When the raw or get methods are called, if the URL doesn't match
      # any of the registerd url patters the fallback providers
      # will be called (in order) with the URL.
      #
      # A common example:
      #  OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery, OEmbed::Providers::Noembed)
      def register_fallback(*providers)
        @@fallback += providers
      end

      # Returns an array of all registerd fallback Provider instances.
      def fallback
        @@fallback
      end

      # Returns a Provider instance whose url scheme matches the given url.
      # Skips any Provider with missing required_query_params.
      def find(url)
        @@urls.keys.each do |url_regexp|
          next unless url_regexp.match?(url)

          matching_provider = @@urls[url_regexp].detect { |p| p.include?(url) }

          # If we've found a matching provider, return it right away!
          return matching_provider if matching_provider
        end

        nil
      end

      # Finds the appropriate Provider for this url and return the raw response.
      # @deprecated *Note*: This method will be made private in the future.
      def raw(url, options = {})
        provider = find(url)
        if provider
          provider.raw(url, options)
        else
          fallback.each do |p|
            return p.raw(url, options) rescue OEmbed::Error
          end
          raise(OEmbed::NotFound)
        end
      end

      # Finds the appropriate Provider for this url and returns an OEmbed::Response,
      # using Provider#get.
      def get(url, options = {})
        provider = find(url)
        if provider
          provider.get(url, options)
        else
          fallback.each do |p|
            return p.get(url, options) rescue OEmbed::Error
          end
          raise(OEmbed::NotFound)
        end
      end

      private

      # Takes an OEmbed::Provider instance and registers it so that when we call
      # the register_all method, they all register.
      # The sub_type can be be any value
      # used to uniquely group providers. Official sub_types are:
      # * nil: a normal provider
      # * :aggregators: an endpoint for an OEmbed aggregator
      # :access_token takes a Hash with the following required keys:
      # * :name: A Symbol: the name of access token, to be used with `register_all`
      # * :method: A Symbol: the name of the required_query_params for the access token.
      def add_official_provider(provider_class, sub_type=nil, access_token: nil)
        raise TypeError, "Expected OEmbed::Provider instance but was #{provider_class.class}" \
          unless provider_class.is_a?(OEmbed::Provider)

        @@to_register[sub_type.to_s] ||= []
        @@to_register[sub_type.to_s] << provider_class

        if access_token.is_a?(Hash) && access_token[:name] && access_token[:method]
          setter_method = "#{access_token[:method]}="
          raise TypeError, "Expected OEmbed::Provider instance to respond to the given access_token method #{setter_method}" \
            unless provider_class.respond_to?(setter_method)

          @@access_token_setters[access_token[:name]] ||= []
          @@access_token_setters[access_token[:name]] << provider_class.method(setter_method)
        end
      end

      # Takes a Hash of tokens, and calls the setter method
      # for all providers that use the given tokens.
      # Also supports "OEMBED_*_TOKEN" environment variables.
      # Currently supported tokens:
      # * facebook: See https://developers.facebook.com/docs/instagram/oembed#access-tokens
      def set_access_tokens(access_tokens)
        access_tokens.each do |token_name, token_value|
          token_name = token_name.to_sym
          next unless @@access_token_setters.has_key?(token_name)

          @@access_token_setters[token_name].each do |token_setter_method|
            token_setter_method.call(token_value)
          end
        end
      end
    end
  end
end
