module OEmbed
  class Providers
    # Provider for scribd.com
    Scribd = OEmbed::Provider.new('https://www.scribd.com/services/oembed')
    Scribd << 'http://*.scribd.com/*'
    add_official_provider(Scribd)
  end
end
