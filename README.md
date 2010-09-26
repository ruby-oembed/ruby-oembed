# ruby-oembed

An oEmbed client written in Ruby, letting you easily get embeddable HTML representations of a supported web pages, based on their URLs. See [oembed.com][oembed] for more about the protocol.

# Installation

    gem install ruby-oembed

# Getting Started

Get embedable resources via an OEmbed::Provider. This gem comes with many Providers built right in, to help you get started.

    resource = OEmbed::Providers::YouTube.get("http://www.youtube.com/watch?v=2BYXBC8WQ5k")
    resource.video? #=> true
    resource.thumbnail_url #=> "http://i3.ytimg.com/vi/2BYXBC8WQ5k/hqdefault.jpg"
    resource.html #=> '<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/2BYXBC8WQ5k?fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/2BYXBC8WQ5k?fs=1" type="application/x-shockwave-flash" width="425" height="344" allowscriptaccess="always" allowfullscreen="true"></embed></object>'

If you'd like to use a provider that isn't included in the library, it's easy to add one, pointing at your own oEmbed API endpoint and providing the relevant URL schemes. 

    my_provider = OEmbed::Provider.new("http://my.cool-service.com/api/oembed_endpoint.{format}"
    my_provider << "http://*.cool-service.com/image/*"
    my_provider << "http://*.cool-service.com/video/*"
    resource = my_provider.get("http://a.cool-service.com/video/1") #=> OEmbed::Response

To use multiple Providers at once, simply register them.

    OEmbed::Providers.register(OEmbed::Providers::YouTube, my_provider)
    resource = OEmbed::Providers.get("http://www.youtube.com/watch?v=2BYXBC8WQ5k") #=> OEmbed::Response
    resource.type #=> "video"
    resource.provider.name #=> "YouTube"

Last but not least, ruby-oembed supports both [oohEmbed][oohembed] and [Embedly][embedly]. These services are provider aggregators. Each supports a wide array of websites ranging from [Amazon.com](http://www.amazon.com) to [xkcd](http://www.xkcd.com).

[oembed]: http://oembed.com "The oembed protocol"
[oohembed]: http://oohembed.com
[embedly]: http://embed.ly