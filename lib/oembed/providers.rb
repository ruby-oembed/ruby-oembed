module OEmbed
  class Providers
    class << self
      @@urls = {}
      
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
        register(Flickr, Viddler, Qik, Pownce, Revision3, Hulu)
      end
      
      def find(url)
        @@urls[@@urls.keys.detect { |u| u =~ url }] || false
      end
      
      def raw(url, options = {})
        provider = find(url) || raise(OEmbed::NotFound)
        provider.raw(url, options)
      end
      
      def get(url, options = {})
        provider = find(url) || raise(OEmbed::NotFound)
        provider.get(url, options)
      end
    end
    
    # Custom providers:
    Flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    Flickr << "http://*.flickr.com/*"     
    
    Viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/")
    Viddler << "http://*.viddler.com/*"
    
    Qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}")
    Qik << "http://qik.com/*"
    
    Pownce = OEmbed::Provider.new("http://api.pownce.com/2.1/oembed.{format}")
    Pownce << "http://*.pownce.com/*"
    
    Revision3 = OEmbed::Provider.new("http://revision3.com/api/oembed/")
    Revision3 << "http://*.revision3.com/*"
    
    Hulu = OEmbed::Provider.new("http://www.hulu.com/api/oembed.{format}")
    Hulu << "http://www.hulu.com/watch/*"
    
    OohEmbed = OEmbed::Provider.new("http://oohembed.com/oohembed/")
  end
end