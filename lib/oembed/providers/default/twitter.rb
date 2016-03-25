module OEmbed
  class Providers
    # Provider for twitter.com
    # https://dev.twitter.com/rest/reference/get/statuses/oembed
    Twitter = OEmbed::Provider.new(
      'https://api.twitter.com/1/statuses/oembed.{format}'
    )
    Twitter << 'https://*.twitter.com/*/status/*'
    add_official_provider(Twitter)
  end
end
