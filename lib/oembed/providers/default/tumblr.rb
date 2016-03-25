module OEmbed
  class Providers
    # Provider for tumblr.com
    Tumblr = OEmbed::Provider.new('http://www.tumblr.com/oembed/1.0/', :json)
    Tumblr << 'http://*.tumblr.com/post/*'
    Tumblr << 'https://*.tumblr.com/post/*'
    add_official_provider(Tumblr)
  end
end
