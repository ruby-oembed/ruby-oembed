module OEmbed
  class Providers
    # Provider for slideshare.net
    # http://www.slideshare.net/developers/oembed
    Slideshare = OEmbed::Provider.new('https://www.slideshare.net/api/oembed/2')
    Slideshare << 'http://www.slideshare.net/*/*'
    Slideshare << 'http://www.slideshare.net/mobile/*/*'
    add_official_provider(Slideshare)
  end
end
