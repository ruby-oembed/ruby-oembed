module OEmbed
  class Providers
    # Provider for my.opera.com
    # http://my.opera.com/devblog/blog/2008/12/02/embedding-my-opera-content-oembed
    MyOpera = OEmbed::Provider.new('http://my.opera.com/service/oembed', :json)
    MyOpera << 'http://my.opera.com/*'
    add_official_provider(MyOpera)
  end
end
