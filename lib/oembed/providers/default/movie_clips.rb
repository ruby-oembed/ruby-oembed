module OEmbed
  class Providers
    # Provider for movieclips.com
    MovieClips = OEmbed::Provider.new('http://movieclips.com/services/oembed/')
    MovieClips << 'http://movieclips.com/watch/*/*/'
    add_official_provider(MovieClips)
  end
end
