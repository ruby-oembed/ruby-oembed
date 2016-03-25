module OEmbed
  class Providers
    # Provider for imgur.com
    Imgur = OEmbed::Provider.new('https://api.imgur.com/oembed.{format}')
    Imgur << 'https://*.imgur.com/gallery/*'
    Imgur << 'http://*.imgur.com/gallery/*'
    add_official_provider(Imgur)
  end
end
