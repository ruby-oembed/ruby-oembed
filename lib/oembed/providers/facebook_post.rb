module OEmbed
  class Providers
    # Provider for Facebook posts
    class FacebookPost < OEmbed::Provider
      def initialize(access_token:)
        super("https://graph.facebook.com/v8.0/oembed_post?access_token=#{access_token}", :json)
        register_urls!
      end

      private

      def register_urls!
        ['https://www.facebook.com/*/posts/*',
         'https://www.facebook.com/*/activity/*',
         'https://www.facebook.com/photo*',
         'https://www.facebook.com/photos*',
         'https://www.facebook.com/*/photos*',
         'https://www.facebook.com/permalink*',
         'https://www.facebook.com/media*',
         'https://www.facebook.com/questions*',
         'https://www.facebook.com/notes*'].each { |u| self << u }
      end
    end
  end
end
