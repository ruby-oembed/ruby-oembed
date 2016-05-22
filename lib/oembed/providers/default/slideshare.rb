module OEmbed
  class Providers
    # Provider for slideshare.net
    # http://www.slideshare.net/developers/oembed
    Slideshare = OEmbed::Provider.new('https://www.slideshare.net/api/oembed/2')
    Slideshare << 'http://*.slideshare.net/*/*'
    Slideshare << 'https://*.slideshare.net/*/*'
    Slideshare << 'http://*.slideshare.net/mobile/*/*'
    Slideshare << 'https://*.slideshare.net/mobile/*/*'
    add_official_provider(Slideshare)
  end
end
