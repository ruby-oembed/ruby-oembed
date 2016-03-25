module OEmbed
  class Providers
    # Provider for 23hq.com
    TwentyThree = OEmbed::Provider.new('http://www.23hq.com/23/oembed')
    TwentyThree << 'http://www.23hq.com/*'
    add_official_provider(TwentyThree)
  end
end
