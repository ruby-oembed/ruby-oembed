module OEmbed
  class Providers
    # Provider for hulu.com
    Hulu = OEmbed::Provider.new('http://www.hulu.com/api/oembed.{format}')
    Hulu << 'http://www.hulu.com/watch/*'
    add_official_provider(Hulu)
  end
end
