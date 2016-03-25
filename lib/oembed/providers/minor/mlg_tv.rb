module OEmbed
  class Providers
    # provider for mlg-tv
    # http://tv.majorleaguegaming.com/oembed
    MlgTv = OEmbed::Provider.new('http://tv.majorleaguegaming.com/oembed')
    MlgTv << 'http://tv.majorleaguegaming.com/video/*'
    MlgTv << 'http://mlg.tv/video/*'
    add_official_provider(MlgTv)
  end
end
