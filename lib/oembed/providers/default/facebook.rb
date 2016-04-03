module OEmbed
  class Providers
    # Providers for Facebook Posts & Videos
    # https://developers.facebook.com/docs/plugins/oembed-endpoints
    FacebookPost = OEmbed::Provider.new(
      'https://www.facebook.com/plugins/post/oembed.json/', :json
    )
    FacebookPost << 'https://www.facebook.com/*/posts/*'
    FacebookPost << 'https://www.facebook.com/*/activity/*'
    FacebookPost << 'https://www.facebook.com/photo*'
    FacebookPost << 'https://www.facebook.com/photos*'
    FacebookPost << 'https://www.facebook.com/*/photos*'
    FacebookPost << 'https://www.facebook.com/permalink*'
    FacebookPost << 'https://www.facebook.com/media*'
    FacebookPost << 'https://www.facebook.com/questions*'
    FacebookPost << 'https://www.facebook.com/notes*'
    add_official_provider(FacebookPost)

    FacebookVideo = OEmbed::Provider.new(
      'https://www.facebook.com/plugins/video/oembed.json/', :json
    )
    FacebookVideo << 'https://www.facebook.com/*/videos/*'
    FacebookVideo << 'https://www.facebook.com/video*'
    add_official_provider(FacebookVideo)
  end
end
