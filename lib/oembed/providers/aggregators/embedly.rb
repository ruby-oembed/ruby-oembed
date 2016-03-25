module OEmbed
  class Providers
    # Provider for Embedly.com, which is a provider aggregator. See
    # OEmbed::Providers::Embedly.urls for a full list of supported url schemas.
    # http://embed.ly/docs/endpoints/1/oembed
    #
    # You can append your Embed.ly API key to the provider so that all requests are signed
    #     OEmbed::Providers::Embedly.endpoint += "?key=#{my_embedly_key}"
    #
    # If you don't yet have an API key you'll need to sign up here: http://embed.ly/pricing
    Embedly = OEmbed::Provider.new('http://api.embed.ly/1/oembed')
    # Add all known URL regexps for Embedly. To update this list run `rake oembed:update_embedly`
    YAML.load_file(File.join(File.dirname(__FILE__), '/embedly_urls.yml')).each do |url|
      Embedly << url
    end
    add_official_provider(Embedly, :aggregators)
  end
end
