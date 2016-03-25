module OEmbed
  class Providers
    # Provider for spotify.com
    # https://twitter.com/nicklas2k/status/330094611202723840
    # http://blog.embed.ly/post/45149936446/oembed-for-spotify
    Spotify = OEmbed::Provider.new('https://embed.spotify.com/oembed/')
    Spotify << 'http://open.spotify.com/*'
    Spotify << 'https://open.spotify.com/*'
    Spotify << 'http://play.spotify.com/*'
    Spotify << 'https://play.spotify.com/*'
    Spotify << /^spotify\:(.*?)/
    add_official_provider(Spotify)
  end
end
