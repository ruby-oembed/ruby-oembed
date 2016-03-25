module OEmbed
  class Providers
    # Provider for clearspring.com
    ClearspringWidgets = OEmbed::Provider.new(
      'http://widgets.clearspring.com/widget/v1/oembed/'
    )
    ClearspringWidgets << 'http://www.clearspring.com/widgets/*'
    add_official_provider(ClearspringWidgets)
  end
end
