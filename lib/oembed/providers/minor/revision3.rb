module OEmbed
  class Providers
    # Provider for revision3.com
    Revision3 = OEmbed::Provider.new('http://revision3.com/api/oembed/')
    Revision3 << 'http://*.revision3.com/*'
    add_official_provider(Revision3)
  end
end
