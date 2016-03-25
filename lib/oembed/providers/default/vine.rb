module OEmbed
  class Providers
    # Provider for vine.co
    # https://dev.twitter.com/web/vine/oembed
    Vine = OEmbed::Provider.new('https://vine.co/oembed.{format}')
    Vine << 'http://*.vine.co/v/*'
    Vine << 'https://*.vine.co/v/*'
    add_official_provider(Vine)
  end
end
