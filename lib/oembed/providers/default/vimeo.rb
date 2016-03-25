module OEmbed
  class Providers
    # Provider for vimeo.com
    # https://developer.vimeo.com/apis/oembed
    Vimeo = OEmbed::Provider.new('https://vimeo.com/api/oembed.{format}')
    Vimeo << 'http://*.vimeo.com/*'
    Vimeo << 'https://*.vimeo.com/*'
    add_official_provider(Vimeo)
  end
end
