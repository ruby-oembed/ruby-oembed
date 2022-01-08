module OEmbed
  class Providers
    # Provider for tiktok.com
    # See https://developers.tiktok.com/doc/embed-videos
    TikTok = OEmbed::Provider.new(
      "https://www.tiktok.com/oembed",
      format: :json
    )
    TikTok << "https://www.tiktok.com/*/video/*"

    add_official_provider(TikTok)
  end
end
