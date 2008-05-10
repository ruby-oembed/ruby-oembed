module OEmbed
  class Providers
    class << self
      @@urls = {}
      
      def register(*providers)
        providers.each do |provider|
          provider.urls.each do |url|
            @@urls[url] = provider
          end
        end
      end
      
      def find(url)
        @@urls[@@urls.keys.detect { |u| u =~ url }] || false
      end
    end
  end
end