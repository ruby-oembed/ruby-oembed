module OEmbed
  class Providers
    # Provider for Facebook videos
    class FacebookVideo < OEmbed::Provider
      def initialize(access_token:)
        super("https://graph.facebook.com/v8.0/oembed_video?access_token=#{access_token}", :json)
        register_urls!
      end

      private

      def register_urls!
        ['https://www.facebook.com/*/videos/*',
         'https://www.facebook.com/video*'].each { |u| self << u }
      end
    end
  end
end
