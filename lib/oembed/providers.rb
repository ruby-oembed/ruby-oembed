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
            @@urls[url] = provider
          end
        end
      end

      def unregister(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            @@urls.delete(url)
          end
        end
      end

      def register_all
        register(Youtube, Flickr, Viddler, Qik, Pownce, Revision3, Hulu, Vimeo, PollEverywhere, MyOpera, ClearspringWidgets, MovieClips, TwentyThree)
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
        @@urls[@@urls.keys.detect { |u| u =~ url }] || false
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
    Youtube = OEmbed::Provider.new("http://www.youtube.com/oembed/")
    Youtube << "http://*.youtube.com/*"

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
    OohEmbed = OEmbed::Provider.new("http://oohembed.com/oohembed/")
    #OohEmbed << %r{http://yfrog.(com|ru|com.tr|it|fr|co.il|co.uk|com.pl|pl|eu|us)/(.*?)} # image & video hosting
    #OohEmbed << "http://*.xkcd.com/*" # A hilarious stick figure comic
    OohEmbed << "http://*.wordpress.com/*/*/*/*" # Blogging Engine & community
    OohEmbed << "http://*.wikipedia.org/wiki/*" # Online encyclopedia
    #OohEmbed << "http://*.twitpic.com/*" # Picture hosting for Twitter
    #OohEmbed << "http://twitter.com/*/statuses/*" # Mirco-blogging network
    #OohEmbed << "http://*.slideshare.net/*" # Share presentations online
    #OohEmbed << "http://*.phodroid.com/*/*/*" # Photo host
    #OohEmbed << "http://*.metacafe.com/watch/*" # Video host
    #OohEmbed << "http://video.google.com/videoplay?*" # Video hosting
    #OohEmbed << "http://*.funnyordie.com/videos/*" # Comedy video host
    OohEmbed << "http://*.thedailyshow.com/video/*" # Syndicated show
    #OohEmbed << "http://*.collegehumor.com/video:*" # Comedic & original videos
    OohEmbed << %r{http://(.*?).amazon.(com|co.uk|de|ca|jp)/(.*?)/(gp/product|o/ASIN|obidos/ASIN|dp)/(.*?)} # Online product shopping
    OohEmbed << "http://*.5min.com/Video/*" # micro-video host

    # A general end point, which then calls other APIs and returns OEmbed info
    Embedly = OEmbed::Provider.new("http://api.embed.ly/v1/api/oembed")
    Embedly <<  "http://*.collegehumor.com/video:*"
    Embedly <<  "http://*.funnyordie.com/videos/*"
    Embedly <<  "http://video.google.com/videoplay?*"
    Embedly <<  "http://www.hulu.com/watch/*"
    Embedly <<  "http://*.metacafe.com/watch/*"
    Embedly <<  "http://twitter.com/*/statuses/*"
    Embedly <<  "http://www.slideshare.net/*/*"
    Embedly <<  "http://*.scribd.com/doc/*"
    Embedly <<  "http://screenr.com/*"
    Embedly <<  "http://www.5min.com/Video/*"
    Embedly <<  "http://www.howcast.com/videos/*"
    Embedly <<  "http://www.clearspring.com/widgets/*"
    Embedly <<  "http://*yfrog.*/*"
    Embedly <<  "http://tweetphoto.com/*"
    Embedly <<  "http://*twitpic.com/*"
    Embedly <<  "http://*imgur.com/*"
    Embedly <<  "http://twitgoo.com/*"
    Embedly <<  "http://phodroid.com/*/*/*"
    Embedly <<  "http://xkcd.com/*"
    Embedly <<  "http://*23hq.com/*/photo/*"
    Embedly <<  "http://www.veoh.com/*/watch/*"
    Embedly <<  "http://*justin.tv/*"
    Embedly <<  %r{http://www.ustream.tv/(recorded|channel)/*}
    Embedly <<  "http://www.twitvid.com/*"
    Embedly <<  "http://www.break.com/*/*"
    Embedly <<  %r{http://(www|vids).myspace.com/index.cfm?fuseaction=*&videoid*}
    Embedly <<  "http://*blip.tv/file/*"
    Embedly <<  "http://*revver.com/video/*"
    Embedly <<  "http://*?liveleak.com/view?*"
    Embedly <<  %r{http://animoto.com/(play|s)/*}
    Embedly <<  "http://dotsub.com/view/*"
    Embedly <<  "http://soundcloud.com/*"
    Embedly <<  %r{http://www.lala.com/#*(album|song)/*}
    Embedly <<  "http://*crackle.com/c/*"
    Embedly <<  "http://www.fancast.com/*/videos"
    Embedly <<  "http://www.ted.com/talks/*.html"
    Embedly <<  "http://*omnisio.com/*"
    Embedly <<  "http://*nfb.ca/film/*"
    Embedly <<  "http://movies.yahoo.com/movie/*/(video|info|trailer)/*"
    Embedly <<  %r{http://www.colbertnation.com/(the-colbert-report-collections|full-episodes|the-colbert-report-videos)/*}
    Embedly <<  "http://www.comedycentral.com/videos/index.jhtml?*"
    Embedly <<  "http://*theonion.com/video/*"
    Embedly <<  "http://wordpress.tv/*/*/*/*/"
    Embedly <<  %r{http://www.traileraddict.com/(trailer|clip|poster)/*}
    Embedly <<  "http://www.escapistmagazine.com/videos/*"
    #Embedly <<  "(http://*?screencast.com/*/media/*|http://*?screencast.com/t/*)"
    #Embedly <<  "(http://my.opera.com/*/albums/show.dml?id=*|http://my.opera.com/*/albums/showpic.dml?album=*&picture=*)"
    #Embedly <<  "(http://i*.photobucket.com/albums/*|http://gi*.photobucket.com/groups/*)"
    #Embedly <<  "(http://*amazon.*/gp/product/*|http://*amazon.*/*/dp/*|http://*amazon.*/dp/*|http://*amazon.*/o/ASIN/*|http://*amazon.*/gp/offer-listing/*|http://*amazon.*/*/ASIN/*|http://*amazon.*/gp/product/images/*)"
    #Embedly <<  "(http://*.dailymotion.com/video/*|http://*.dailymotion.com/*/video/*)"
    #Embedly <<  "(http://video.yahoo.com/watch/*/*|http://video.yahoo.com/network/*)"
    #Embedly <<  "(http://movieclips.com/watch/*/*/|http://movieclips.com/watch/*/*/*/*)"
    #Embedly <<  "(http://www.thedailyshow.com/(watch|full-episodes)/*|http://www.thedailyshow.com/collection/*/*/*)"
    
    
    
    



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
