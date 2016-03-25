module OEmbed
  class Providers
    # Provider for instagram.com
    # https://instagr.am/developer/embedding/
    Instagram = OEmbed::Provider.new('https://api.instagram.com/oembed', :json)
    Instagram << 'http://instagr.am/p/*'
    Instagram << 'http://instagram.com/p/*'
    Instagram << 'http://www.instagram.com/p/*'
    Instagram << 'https://instagr.am/p/*'
    Instagram << 'https://instagram.com/p/*'
    Instagram << 'https://www.instagram.com/p/*'
    add_official_provider(Instagram)
  end
end
