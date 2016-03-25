module OEmbed
  class Providers
    # Provider for viddler.com
    # http://developers.viddler.com/#oembed
    Viddler = OEmbed::Provider.new('http://www.viddler.com/oembed/')
    Viddler << 'http://*.viddler.com/*'
    add_official_provider(Viddler)
  end
end
