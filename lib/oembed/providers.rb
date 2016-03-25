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
      def register_all(*including_sub_type)
        register(*@@to_register[''])
        including_sub_type.each do |sub_type|
          register(*@@to_register[sub_type.to_s])
        end
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
      #  OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery, OEmbed::Providers::OohEmbed)
      def register_fallback(*providers)
        @@fallback += providers
      end

      # Returns an array of all registerd fallback Provider instances.
      def fallback
        @@fallback
      end

      # Returns a Provider instance who's url scheme matches the given url.
      def find(url)
        providers = @@urls[@@urls.keys.detect { |u| u =~ url }]
        Array(providers).first || nil
      end

      # Finds the appropriate Provider for this url and return the raw response.
      # @deprecated *Note*: This method will be made private in the future.
      def raw(url, options = {})
        provider = find(url)
        if provider
          provider.raw(url, options)
        else
          fallback.each do |p|
            begin
              return p.raw(url, options)
            rescue
              OEmbed::Error
            end
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
            begin
              return p.get(url, options)
            rescue
              OEmbed::Error
            end
          end
          raise(OEmbed::NotFound)
        end
      end

      private

      # Takes an OEmbed::Provider instance and registers it so that when we call
      # the register_all method, they all register. The sub_type can be be any value
      # used to uniquely group providers. Official sub_types are:
      # * nil: a normal provider
      # * :aggregators: an endpoint for an OEmbed aggregator
      def add_official_provider(provider_class, sub_type = nil)
        raise TypeError, "Expected OEmbed::Provider instance but was #{provider_class.class}" \
          unless provider_class.is_a?(OEmbed::Provider)

        @@to_register[sub_type.to_s] ||= []
        @@to_register[sub_type.to_s] << provider_class
      end
    end
  end
end
