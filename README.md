# ruby-oembed

An oEmbed client written in Ruby, letting you easily get embeddable HTML representations of a supported web pages, based on their URLs. See [oembed.com][oembed] for more about the protocol.

# Installation

    gem install ruby-oembed

# Get Started

You get embedable resources via an OEmbed::Provider. This gem comes with many Providers built right in, to make your life easy.

    resource = OEmbed::Providers::YouTube.get("http://www.youtube.com/watch?v=2BYXBC8WQ5k")
    resource.video? #=> true
    resource.thumbnail_url #=> "http://i3.ytimg.com/vi/2BYXBC8WQ5k/hqdefault.jpg"
    resource.html #=> '<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/2BYXBC8WQ5k?fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/2BYXBC8WQ5k?fs=1" type="application/x-shockwave-flash" width="425" height="344" allowscriptaccess="always" allowfullscreen="true"></embed></object>'

If you'd like to use a provider that isn't included in the library, it's easy to add one. Just provide the oEmbed API endpoint and URL scheme(s). 

    my_provider = OEmbed::Provider.new("http://my.cool-service.com/api/oembed_endpoint.{format}"
    my_provider << "http://*.cool-service.com/image/*"
    my_provider << "http://*.cool-service.com/video/*"
    resource = my_provider.get("http://a.cool-service.com/video/1") #=> OEmbed::Response
    resource.provider.name #=> "My Cool Service"

To use multiple Providers at once, simply register them.

    OEmbed::Providers.register(OEmbed::Providers::YouTube, my_provider)
    resource = OEmbed::Providers.get("http://www.youtube.com/watch?v=2BYXBC8WQ5k") #=> OEmbed::Response
    resource.type #=> "video"
    resource.provider.name #=> "YouTube"

Last but not least, ruby-oembed supports both [oohEmbed][oohembed] and [Embedly][embedly]. These services are provider aggregators. Each supports a wide array of websites ranging from [Amazon.com](http://www.amazon.com) to [xkcd](http://www.xkcd.com).

# Lend a Hand

Code for the ruby-oembed library is [hosted on GitHub][ruby-oembed].

If you encounter any bug, feel free to [Create an Issue](http://github.com/judofyr/ruby-oembed/issues).

To submit a patch, please [fork](http://help.github.com/forking/) the library and commit your changes along with relevant tests. Once you're happy with the changes, [send a pull request](http://help.github.com/pull-requests/).

# License

This code is free to use under the terms of the MIT license.

[ruby-oembed]: http://github.com/judofyr/ruby-oembed "The ruby-oembed Library"
[oembed]: http://oembed.com "The oEmbed protocol"
[oohembed]: http://oohembed.com
[embedly]: http://embed.ly