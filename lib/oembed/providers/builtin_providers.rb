# This file is used to load all built-in providers.
# In the short term most of them are specified in this file
# though we've _started_ moving provider definitions into their own files!

require 'oembed/providers/facebook_post'
require 'oembed/providers/facebook_video'
require 'oembed/providers/instagram'
require 'oembed/providers/matterport'
require 'oembed/providers/spotify'
require 'oembed/providers/tiktok'

module OEmbed
  class Providers
    # Provider for youtube.com
    # http://apiblog.youtube.com/2009/10/oembed-support.html
    #
    # Options:
    # * To get the iframe embed code
    #     OEmbed::Providers::Youtube.endpoint += "?iframe=1"
    # * To get the flash/object embed code
    #     OEmbed::Providers::Youtube.endpoint += "?iframe=0"
    # * To require https embed code
    #     OEmbed::Providers::Youtube.endpoint += "?scheme=https"
    Youtube = OEmbed::Provider.new("https://www.youtube.com/oembed/?scheme=https")
    Youtube << "http://*.youtube.com/*"
    Youtube << "https://*.youtube.com/*"
    Youtube << "http://*.youtu.be/*"
    Youtube << "https://*.youtu.be/*"
    add_official_provider(Youtube)

    # Provider for codepen.io
    CodePen = OEmbed::Provider.new("https://codepen.io/api/oembed")
    CodePen << "http://codepen.io/*"
    CodePen << "https://codepen.io/*"
    add_official_provider(CodePen)

    # Provider for flickr.com
    Flickr = OEmbed::Provider.new("https://www.flickr.com/services/oembed/")
    Flickr << "http://*.flickr.com/*"
    Flickr << "https://*.flickr.com/*"
    Flickr << "http://flic.kr/*"
    Flickr << "https://flic.kr/*"
    add_official_provider(Flickr)

    # Provider for vimeo.com
    # https://developer.vimeo.com/apis/oembed
    Vimeo = OEmbed::Provider.new("https://vimeo.com/api/oembed.{format}")
    Vimeo << "http://*.vimeo.com/*"
    Vimeo << "https://*.vimeo.com/*"
    add_official_provider(Vimeo)

    # Provider for twitter.com
    # https://dev.twitter.com/rest/reference/get/statuses/oembed
    Twitter = OEmbed::Provider.new("https://publish.twitter.com/oembed", format: :json)
    Twitter << "https://*.twitter.com/*/status/*"
    Twitter << "https://*.x.com/*/status/*"
    add_official_provider(Twitter)

    # Provider for vine.co
    # https://dev.twitter.com/web/vine/oembed
    Vine = OEmbed::Provider.new("https://vine.co/oembed.{format}")
    Vine << "http://*.vine.co/v/*"
    Vine << "https://*.vine.co/v/*"
    add_official_provider(Vine)

    # Provider for slideshare.net
    # http://www.slideshare.net/developers/oembed
    Slideshare = OEmbed::Provider.new("https://www.slideshare.net/api/oembed/2")
    Slideshare << 'http://*.slideshare.net/*/*'
    Slideshare << 'https://*.slideshare.net/*/*'
    Slideshare << 'http://*.slideshare.net/mobile/*/*'
    Slideshare << 'https://*.slideshare.net/mobile/*/*'
    add_official_provider(Slideshare)

    # Provider for Giphy
    Giphy = OEmbed::Provider.new("http://giphy.com/services/oembed")
    Giphy << "http://giphy.com/*"
    Giphy << "https://giphy.com/*"
    add_official_provider(Giphy)

    # Provider for imgur.com
    Imgur = OEmbed::Provider.new("https://api.imgur.com/oembed.{format}")
    Imgur << "https://*.imgur.com/gallery/*"
    Imgur << "http://*.imgur.com/gallery/*"
    add_official_provider(Imgur)

    # Provider for Kickstarter
    Kickstarter = OEmbed::Provider.new("https://www.kickstarter.com/services/oembed")
    Kickstarter << "http://www.kickstarter.com/projects/*"
    Kickstarter << "https://www.kickstarter.com/projects/*"
    add_official_provider(Kickstarter)

    # Provider for polleverywhere.com
    PollEverywhere = OEmbed::Provider.new("http://www.polleverywhere.com/services/oembed/")
    PollEverywhere << "http://www.polleverywhere.com/polls/*"
    PollEverywhere << "http://www.polleverywhere.com/multiple_choice_polls/*"
    PollEverywhere << "http://www.polleverywhere.com/free_text_polls/*"
    add_official_provider(PollEverywhere)

    # Provider for nfb.ca
    NFBCanada = OEmbed::Provider.new("http://www.nfb.ca/remote/services/oembed/")
    NFBCanada << "http://*.nfb.ca/film/*"
    add_official_provider(NFBCanada)

    # Provider for scribd.com
    Scribd = OEmbed::Provider.new("https://www.scribd.com/services/oembed")
    Scribd << "http://*.scribd.com/*"
    add_official_provider(Scribd)

    # Provider for speakerdeck.com
    # https://speakerdeck.com/faq#oembed
    SpeakerDeck = OEmbed::Provider.new("https://speakerdeck.com/oembed.json")
    SpeakerDeck << "http://speakerdeck.com/*/*"
    SpeakerDeck << "https://speakerdeck.com/*/*"
    add_official_provider(SpeakerDeck)

    # Provider for 23hq.com
    TwentyThree = OEmbed::Provider.new("http://www.23hq.com/23/oembed")
    TwentyThree << "http://www.23hq.com/*"
    add_official_provider(TwentyThree)

    # Provider for soundcloud.com
    # http://developers.soundcloud.com/docs/oembed
    SoundCloud = OEmbed::Provider.new("https://soundcloud.com/oembed", format: :json)
    SoundCloud << "http://*.soundcloud.com/*"
    SoundCloud << "https://*.soundcloud.com/*"
    add_official_provider(SoundCloud)

    # Provider for TED
    Ted = OEmbed::Provider.new("https://www.ted.com/talks/oembed.{format}")
    Ted << "http://*.ted.com/talks/*"
    Ted << "https://*.ted.com/talks/*"
    add_official_provider(Ted)

    # Provider for tumblr.com
    Tumblr = OEmbed::Provider.new("http://www.tumblr.com/oembed/1.0/", format: :json)
    Tumblr << "http://*.tumblr.com/post/*"
    Tumblr << "https://*.tumblr.com/post/*"
    add_official_provider(Tumblr)

    # Provider for noembed.com, which is a provider aggregator. See
    # OEmbed::Providers::Noembed.urls for a full list of supported url schemas.
    # https://noembed.com/#supported-sites
    Noembed = OEmbed::Provider.new("https://noembed.com/embed")
    # Add all known URL regexps for Noembed.
    # To update this list run `rake oembed:update_noembed`
    YAML.load_file(File.join(File.dirname(__FILE__), "/aggregators/noembed_urls.yml")).each do |url|
      Noembed << Regexp.new(url)
    end
    add_official_provider(Noembed, :aggregators)

    # Provider for Embedly.com, which is a provider aggregator. See
    # OEmbed::Providers::Embedly.urls for a full list of supported url schemas.
    # http://embed.ly/docs/endpoints/1/oembed
    #
    # You can append your Embed.ly API key to the provider so that all requests are signed
    #     OEmbed::Providers::Embedly.endpoint += "?key=#{my_embedly_key}"
    #
    # If you don't yet have an API key you'll need to sign up here: http://embed.ly/pricing
    Embedly = OEmbed::Provider.new("http://api.embed.ly/1/oembed")
    # Add all known URL regexps for Embedly. To update this list run `rake oembed:update_embedly`
    YAML.load_file(File.join(File.dirname(__FILE__), "/aggregators/embedly_urls.yml")).each do |url|
      Embedly << url
    end
    add_official_provider(Embedly, :aggregators)
  end
end
