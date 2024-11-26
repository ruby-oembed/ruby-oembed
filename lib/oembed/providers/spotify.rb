module OEmbed
  class Providers
    # Provider for spotify.com
    # https://developer.spotify.com/documentation/embeds/reference/oembed
    # https://developer.spotify.com/documentation/embeds/tutorials/using-the-oembed-api
    Spotify = OEmbed::Provider.new(
      "https://open.spotify.com/oembed",
      format: :json
    )
    Spotify << "http://open.spotify.com/*"
    Spotify << "https://open.spotify.com/*"
    Spotify << "http://play.spotify.com/*"
    Spotify << "https://play.spotify.com/*"
    Spotify << /^spotify\:(.*?)/

    add_official_provider(Spotify)
  end
end
