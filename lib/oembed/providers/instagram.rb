module OEmbed
  class Providers
    # Provider for instagram.com
    class Instagram < OEmbed::Provider
      def initialize(access_token:)
        super("https://graph.facebook.com/v8.0/instagram_oembed?access_token=#{access_token}", :json)
        register_urls!
      end

      private

      def register_urls!
        ["http://instagr.am/p/*",
         "http://instagram.com/p/*",
         "http://www.instagram.com/p/*",
         "https://instagr.am/p/*",
         "https://instagram.com/p/*",
         "https://www.instagram.com/p/*",
         "http://instagr.am/tv/*",
         "http://instagram.com/tv/*",
         "http://www.instagram.com/tv/*",
         "https://instagr.am/tv/*",
         "https://instagram.com/tv/*",
         "https://www.instagram.com/tv/*"].each { |u| self << u }
      end
    end
  end
end
