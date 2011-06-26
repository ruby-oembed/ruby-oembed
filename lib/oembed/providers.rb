require 'rubygems'
require 'yaml'

module OEmbed
  # Allows OEmbed to perform tasks across several, registered, Providers
  # at once.
  class Providers
    class << self
      @@urls = {}
      @@fallback = []

      # A Hash of all url schemes, where the keys represent schemes supported by
      # all registered Provider instances and values are an Array of Providers
      # that support that scheme.
      def urls
        @@urls
      end

      # Given one ore more Provider instances, register their url schemes for
      # future get calls.
      def register(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            @@urls[url] ||= []
            @@urls[url] << provider
          end
        end
      end

      # Given one ore more Provider instances, un-register their url schemes.
      # Future get calls will not use these Providers.
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

      # Register a standard set of common Provider instances, including:
      # * Flickr
      # * Hulu
      # * Qik
      # * Revision3
      # * Viddler
      # * Vimeo
      # * Youtube
      def register_all
        register(Youtube, Flickr, Viddler, Qik, Revision3, Hulu, Vimeo)
      end

      # Unregister all currently-registered Provider instances.
      def unregister_all
        @@urls = {}
        @@fallback = []
      end

      # Takes an array of Provider instances or ProviderDiscovery
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

      # Returns an array of all registerd fallback Provider instances.
      def fallback
        @@fallback
      end

      # Returns a Provider instance who's url scheme matches the given url.
      def find(url)
        providers = @@urls[@@urls.keys.detect { |u| u =~ url }]
        Array(providers).first || nil
      end

      # Finds the appropriate Provider for this url and return the raw response.
      # @deprecated *Note*: This method will be made private in the future.
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

      # Finds the appropriate Provider for this url and returns an OEmbed::Response,
      # using Provider#get.
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
    
    # Provider for youtube.com
    # http://apiblog.youtube.com/2009/10/oembed-support.html
    # To get the iframe embed code, instead of flash-based, pass
    # :flash=>1 as a query in your get request.
    Youtube = OEmbed::Provider.new("http://www.youtube.com/oembed")
    Youtube << "http://*.youtube.com/*"
    Youtube << "http://*.youtu.be/*"

    # Provider for flickr.com
    # http://developer.yahoo.com/blogs/ydn/posts/2008/05/oembed_embeddin/
    Flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    Flickr << "http://*.flickr.com/*"

    # Provider for viddler.com
    # http://developers.viddler.com/documentation/services/oembed/
    Viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/")
    Viddler << "http://*.viddler.com/*"

    # Provider for qik.com
    # http://qik.com/blog/qik-embraces-oembed-for-embedding-videos/
    Qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}")
    Qik << "http://qik.com/*"
    Qik << "http://qik.com/video/*"

    # Provider for revision3.com
    Revision3 = OEmbed::Provider.new("http://revision3.com/api/oembed/")
    Revision3 << "http://*.revision3.com/*"

    # Provider for hulu.com
    Hulu = OEmbed::Provider.new("http://www.hulu.com/api/oembed.{format}")
    Hulu << "http://www.hulu.com/watch/*"

    # Provider for vimeo.com
    # http://vimeo.com/api/docs/oEmbed
    Vimeo = OEmbed::Provider.new("http://www.vimeo.com/api/oembed.{format}")
    Vimeo << "http://*.vimeo.com/*"
    Vimeo << "http://*.vimeo.com/groups/*/videos/*"
    
    # Provider for instagram.com
    # http://instagr.am/developer/embedding/
    Instagram = OEmbed::Provider.new("http://api.instagram.com/oembed", :json)
    Instagram << "http://instagr.am/p/*"
    Instagram << "http://instagram.com/p/*"
    
    # Provider for slideshare.net
    # http://www.slideshare.net/developers/oembed
    Slideshare = OEmbed::Provider.new("http://www.slideshare.net/api/oembed/2")
    Slideshare << "http://www.slideshare.net/*/*"
    Slideshare << "http://www.slideshare.net/mobile/*/*"
    
    # Provider for yfrog
    # http://code.google.com/p/imageshackapi/wiki/OEMBEDSupport
    Yfrog = OEmbed::Provider.new("http://www.yfrog.com/api/oembed", :json)
    Yfrog << "http://yfrog.com/*"
    

    # pownce.com closed in 2008
    #Pownce = OEmbed::Provider.new("http://api.pownce.com/2.1/oembed.{format}")
    #Pownce << "http://*.pownce.com/*"

    # Provider for oohembed.com, which is a provider agregator. See
    # OEmbed::Providers::OohEmbed.urls for a full list of supported url schemas.
    # Embed.ly has taken over the oohembed.com domain and as of July 20 all oohEmbed
    # request will require you use an API key. For details on the transition see
    # http://blog.embed.ly/oohembed
    OohEmbed = OEmbed::Provider.new("http://oohembed.com/oohembed/", :json)
    OohEmbed << "http://*.5min.com/Video/*" # micro-video host
    OohEmbed << %r{http://(.*?).amazon.(com|co.uk|de|ca|jp)/(.*?)/(gp/product|o/ASIN|obidos/ASIN|dp)/(.*?)} # Online product shopping
    OohEmbed << "http://*.blip.tv/*"
    OohEmbed << "http://*.clikthrough.com/theater/video/*"
    OohEmbed << "http://*.collegehumor.com/video:*" # Comedic & original videos
    OohEmbed << "http://*.thedailyshow.com/video/*" # Syndicated show
    OohEmbed << "http://*.dailymotion.com/*"
    OohEmbed << "http://dotsub.com/view/*"
    OohEmbed << "http://*.flickr.com/photos/*"
    OohEmbed << "http://*.funnyordie.com/videos/*" # Comedy video host
    OohEmbed << "http://video.google.com/videoplay?*" # Video hosting
    OohEmbed << "http://www.hulu.com/watch/*"
    OohEmbed << "http://*.kinomap.com/*"
    OohEmbed << "http://*.livejournal.com/"
    OohEmbed << "http://*.metacafe.com/watch/*" # Video host
    OohEmbed << "http://*.nfb.ca/film/*"
    OohEmbed << "http://*.photobucket.com/albums/*"
    OohEmbed << "http://*.photobucket.com/groups/*"
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

    # Provider for Embedly.com, which is a provider agregator. See
    # OEmbed::Providers::Embedly.urls for a full list of supported url schemas.
    # http://embed.ly/docs/endpoints/1/oembed
    # You'll need to add your Embed.ly API key to each request as the "key"
    # parameter. To get an API key you'll need to sign up here: http://embed.ly/pricing
    Embedly = OEmbed::Provider.new("http://api.embed.ly/1/oembed")
    # Add all known URL regexps for Embedly. To update this list run `rake oembed:update_embedly`
    YAML.load_file(File.join(File.dirname(__FILE__), "/providers/embedly_urls.yml")).each do |url|
      Embedly << url
    end
    
    # Provider for polleverywhere.com
    PollEverywhere = OEmbed::Provider.new("http://www.polleverywhere.com/services/oembed/")
    PollEverywhere << "http://www.polleverywhere.com/polls/*"
    PollEverywhere << "http://www.polleverywhere.com/multiple_choice_polls/*"
    PollEverywhere << "http://www.polleverywhere.com/free_text_polls/*"

    # Provider for my.opera.com
    # http://my.opera.com/devblog/blog/2008/12/02/embedding-my-opera-content-oembed
    MyOpera = OEmbed::Provider.new("http://my.opera.com/service/oembed", :json)
    MyOpera << "http://my.opera.com/*"

    # Provider for clearspring.com
    ClearspringWidgets = OEmbed::Provider.new("http://widgets.clearspring.com/widget/v1/oembed/")
    ClearspringWidgets << "http://www.clearspring.com/widgets/*"

    # Provider for nfb.ca
    NFBCanada = OEmbed::Provider.new("http://www.nfb.ca/remote/services/oembed/")
    NFBCanada << "http://*.nfb.ca/film/*"

    # Provider for scribd.com
    Scribd = OEmbed::Provider.new("http://www.scribd.com/services/oembed")
    Scribd << "http://*.scribd.com/*"

    # Provider for movieclips.com
    MovieClips = OEmbed::Provider.new("http://movieclips.com/services/oembed/")
    MovieClips << "http://movieclips.com/watch/*/*/"

    # Provider for 23hq.com
    TwentyThree = OEmbed::Provider.new("http://www.23hq.com/23/oembed")
    TwentyThree << "http://www.23hq.com/*"
    
    # Provider for clikthrough.com
    #Clickthrough = OEmbed::Provider.new("http://www.clikthrough.com/services/oembed/")
    #Clickthrough << "http://*.clikthrough.com/theater/video/*"
    #
    ## Provider for kinomap.com
    #Kinomap = OEmbed::Provider.new("http://www.kinomap.com/oembed")
    #Kinomap << "http://www.kinomap.com/*"
  end
end
