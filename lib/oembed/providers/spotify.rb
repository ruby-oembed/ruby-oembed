module OEmbed
  class Providers
    # Provider for spotify.com
    # See https://developer.spotify.com/documentation/embeds/tutorials/using-the-oembed-api
    Spotify = OEmbed::Provider.new("https://embed.spotify.com/oembed/")
    Spotify << "http://open.spotify.com/*"
    Spotify << "https://open.spotify.com/*"
    Spotify << "http://play.spotify.com/*"
    Spotify << "https://play.spotify.com/*"
    Spotify << /^spotify\:(.*?)/

    add_official_provider(Spotify)
  end
end
