module OEmbed
  class Providers
    # Provider for twitter.com
    # https://dev.twitter.com/rest/reference/get/statuses/oembed
    Twitter = OEmbed::Provider.new('https://publish.twitter.com/oembed', :json)
    Twitter << 'https://*.twitter.com/*/status/*'
    add_official_provider(Twitter)
  end
end
