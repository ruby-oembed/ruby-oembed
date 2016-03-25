module OEmbed
  class Providers
    # Provider for soundcloud.com
    # http://developers.soundcloud.com/docs/oembed
    SoundCloud = OEmbed::Provider.new('https://soundcloud.com/oembed', :json)
    SoundCloud << 'http://*.soundcloud.com/*'
    SoundCloud << 'https://*.soundcloud.com/*'
    add_official_provider(SoundCloud)
  end
end
