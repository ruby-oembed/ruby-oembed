module OEmbed
  class Providers
    # Provider for kinomap.com
    # http://www.kinomap.com/#!oEmbed
    Kinomap = OEmbed::Provider.new('http://www.kinomap.com/oembed')
    Kinomap << 'http://www.kinomap.com/*'
    add_official_provider(Kinomap)
  end
end
