module OEmbed
  class Providers
    # Provider for my.matterport.com
    Matterport = OEmbed::Provider.new(
      "https://my.matterport.com/api/v1/models/oembed/",
      format: :json
    )
    Matterport << "https://*.matterport.com/show/*"

    add_official_provider(Matterport)
  end
end
