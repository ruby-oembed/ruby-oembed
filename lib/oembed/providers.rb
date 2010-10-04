require 'rubygems'
require 'json'

module OEmbed
  class Providers
    class << self
      @@urls = {}
      @@fallback = []

      def urls
        @@urls
      end

      def register(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            @@urls[url] ||= []
            @@urls[url] << provider
          end
        end
      end

      def unregister(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            if @@urls[url].is_a?(Array)
              @@urls[url].delete(provider)
              @@urls.delete(url) if @@urls[url].empty?
            end
          end
        end
      end

      def register_all
        register(Youtube, Flickr, Viddler, Qik, Pownce, Revision3, Hulu, Vimeo)
      end

      # Takes an array of OEmbed::Provider instances or OEmbed::ProviderDiscovery
      # Use this method to register fallback providers.
      # When the raw or get methods are called, if the URL doesn't match
      # any of the registerd url patters the fallback providers
      # will be called (in order) with the URL.
      #
      # A common example:
      #  OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery, OEmbed::Providers::OohEmbed)
      def register_fallback(*providers)
        @@fallback += providers
      end

      # Returns an array of all registerd fallback providers
      def fallback
        @@fallback
      end

      def find(url)
        providers = @@urls[@@urls.keys.detect { |u| u =~ url }]
        Array(providers).first || nil
      end

      def raw(url, options = {})
        provider = find(url)
        if provider
          provider.raw(url, options)
        else
          fallback.each do |p|
            return p.raw(url, options) rescue OEmbed::Error
          end
          raise(OEmbed::NotFound)
        end
      end

      def get(url, options = {})
        provider = find(url)
        if provider
          provider.get(url, options)
        else
          fallback.each do |p|
            return p.get(url, options) rescue OEmbed::Error
          end
          raise(OEmbed::NotFound)
        end
      end
    end

    # Custom providers:
    Youtube = OEmbed::Provider.new("http://www.youtube.com/oembed")
    Youtube << "http://*.youtube.com/*"
    Youtube << "http://*.youtu.be/*"

    Flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    Flickr << "http://*.flickr.com/*"

    Viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/")
    Viddler << "http://*.viddler.com/*"

    Qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}")
    Qik << "http://qik.com/*"
    Qik << "http://qik.com/video/*"

    Revision3 = OEmbed::Provider.new("http://revision3.com/api/oembed/")
    Revision3 << "http://*.revision3.com/*"

    Hulu = OEmbed::Provider.new("http://www.hulu.com/api/oembed.{format}")
    Hulu << "http://www.hulu.com/watch/*"

    Vimeo = OEmbed::Provider.new("http://www.vimeo.com/api/oembed.{format}")
    Vimeo << "http://*.vimeo.com/*"
    Vimeo << "http://*.vimeo.com/groups/*/videos/*"

    Pownce = OEmbed::Provider.new("http://api.pownce.com/2.1/oembed.{format}")
    Pownce << "http://*.pownce.com/*"

    # A general end point, which then calls other APIs and returns OEmbed info
    OohEmbed = OEmbed::Provider.new("http://oohembed.com/oohembed/", :json)
    OohEmbed << "http://*.5min.com/Video/*" # micro-video host
    OohEmbed << %r{http://(.*?).amazon.(com|co.uk|de|ca|jp)/(.*?)/(gp/product|o/ASIN|obidos/ASIN|dp)/(.*?)} # Online product shopping
    OohEmbed << "http://*.blip.tv/*"
    OohEmbed << "http://*.collegehumor.com/video:*" # Comedic & original videos
    OohEmbed << "http://*.thedailyshow.com/video/*" # Syndicated show
    OohEmbed << "http://*.dailymotion.com/*"
    OohEmbed << "http://dotsub.com/view/*"
    OohEmbed << "http://*.flickr.com/photos/*"
    OohEmbed << "http://*.funnyordie.com/videos/*" # Comedy video host
    OohEmbed << "http://video.google.com/videoplay?*" # Video hosting
    OohEmbed << "http://www.hulu.com/watch/*"
    OohEmbed << "http://*.livejournal.com/"
    OohEmbed << "http://*.metacafe.com/watch/*" # Video host
    OohEmbed << "http://*.nfb.ca/film/*"
    OohEmbed << "http://*.phodroid.com/*/*/*" # Photo host
    OohEmbed << "http://qik.com/*"
    OohEmbed << "http://*.revision3.com/*"
    OohEmbed << "http://*.scribd.com/*"
    OohEmbed << "http://*.slideshare.net/*" # Share presentations online
    OohEmbed << "http://*.twitpic.com/*" # Picture hosting for Twitter
    OohEmbed << "http://twitter.com/*/statuses/*" # Mirco-blogging network
    OohEmbed << "http://*.viddler.com/explore/*"
    OohEmbed << "http://www.vimeo.com/*"
    OohEmbed << "http://www.vimeo.com/groups/*/videos/*"
    OohEmbed << "http://*.wikipedia.org/wiki/*" # Online encyclopedia
    OohEmbed << "http://*.wordpress.com/*/*/*/*" # Blogging Engine & community
    OohEmbed << "http://*.xkcd.com/*" # A hilarious stick figure comic
    OohEmbed << %r{http://yfrog.(com|ru|com.tr|it|fr|co.il|co.uk|com.pl|pl|eu|us)/(.*?)} # image & video hosting
    OohEmbed << "http://*.youtube.com/watch*"

    # A general end point, which then calls other APIs and returns OEmbed info
    Embedly = OEmbed::Provider.new("http://api.embed.ly/v1/api/oembed")
    # An up-to-date version of this json file is available here: (http://api.embed.ly/static/data/embedly_regex.json
    JSON.parse(File.open(File.dirname(__FILE__) + "/embedly_urls.json", "r").read).each do |url|
      Embedly << url
    end
    
    PollEverywhere = OEmbed::Provider.new("http://www.polleverywhere.com/services/oembed/")
    PollEverywhere << "http://www.polleverywhere.com/polls/*"
    PollEverywhere << "http://www.polleverywhere.com/multiple_choice_polls/*"
    PollEverywhere << "http://www.polleverywhere.com/free_text_polls/*"

    MyOpera = OEmbed::Provider.new("http://my.opera.com/service/oembed", :json)
    MyOpera << "http://my.opera.com/*"

    ClearspringWidgets = OEmbed::Provider.new("http://widgets.clearspring.com/widget/v1/oembed/")
    ClearspringWidgets << "http://www.clearspring.com/widgets/*"

    NFBCanada = OEmbed::Provider.new("http://www.nfb.ca/remote/services/oembed/")
    NFBCanada << "http://*.nfb.ca/film/*"

    Scribd = OEmbed::Provider.new("http://www.scribd.com/services/oembed")
    Scribd << "http://*.scribd.com/*"

    MovieClips = OEmbed::Provider.new("http://movieclips.com/services/oembed/")
    MovieClips << "http://movieclips.com/watch/*/*/"

    TwentyThree = OEmbed::Provider.new("http://www.23hq.com/23/oembed")
    TwentyThree << "http://www.23hq.com/*"

  end
end
