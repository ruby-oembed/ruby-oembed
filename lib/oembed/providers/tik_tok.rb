module OEmbed
  class Providers
    # Provider for TikTok
    # See https://developers.tiktok.com/doc/Embed
    TikTok = OEmbed::Provider.new("https://www.tiktok.com/oembed")

    TikTok << "https://www.tiktok.com/*/video/*"

    add_official_provider(TikTok)
  end
end
