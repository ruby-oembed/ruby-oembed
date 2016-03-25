module OEmbed
  class Providers
    # Provider for flickr.com
    Flickr = OEmbed::Provider.new('https://www.flickr.com/services/oembed/')
    Flickr << 'http://*.flickr.com/*'
    Flickr << 'https://*.flickr.com/*'
    Flickr << 'http://flic.kr/*'
    Flickr << 'https://flic.kr/*'
    add_official_provider(Flickr)
  end
end
