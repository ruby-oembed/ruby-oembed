module OEmbed
  class Providers
    # Provider for youtube.com
    # http://apiblog.youtube.com/2009/10/oembed-support.html
    #
    # Options:
    # * To get the iframe embed code
    #     OEmbed::Providers::Youtube.endpoint += "?iframe=1"
    # * To get the flash/object embed code
    #     OEmbed::Providers::Youtube.endpoint += "?iframe=0"
    # * To require https embed code
    #     OEmbed::Providers::Youtube.endpoint += "?scheme=https"
    Youtube = OEmbed::Provider.new('https://www.youtube.com/oembed?scheme=https')
    Youtube << 'http://*.youtube.com/*'
    Youtube << 'https://*.youtube.com/*'
    Youtube << 'http://*.youtu.be/*'
    Youtube << 'https://*.youtu.be/*'
    add_official_provider(Youtube)
  end
end
