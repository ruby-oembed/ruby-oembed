module OEmbed
  class Providers
    # Provider for Facebook posts
    # See https://developers.facebook.com/docs/plugins/oembed
    # See https://developers.facebook.com/docs/graph-api/reference/v8.0/oembed-post
    FacebookPost = OEmbed::Provider.new(
      "https://graph.facebook.com/v8.0/oembed_post",
      required_query_params: { access_token: 'OEMBED_FACEBOOK_TOKEN' },
      format: :json
    )
    FacebookPost << 'https://www.facebook.com/*/posts/*'
    FacebookPost << 'https://www.facebook.com/*/activity/*'
    FacebookPost << 'https://www.facebook.com/photo*'
    FacebookPost << 'https://www.facebook.com/*/photo*'
    FacebookPost << 'https://www.facebook.com/media*'
    FacebookPost << 'https://www.facebook.com/questions*'
    FacebookPost << 'https://www.facebook.com/notes*'

    # Note: even though FacebookPost is automatically registered as an official provider
    # it will NOT resolve any URLs unless its access_token is set
    # either via the OEMBED_FACEBOOK_TOKEN environment variable
    # or by calling `OEmbed::Providers::FacebookPost.access_token = @your_token`
    add_official_provider(FacebookPost, nil, access_token: {name: :facebook, method: :access_token})

    # Respond to the `new` method to maintain backwards compatibility with v0.14.0
    # See also:
    # * https://github.com/ruby-oembed/ruby-oembed/pull/75
    # * https://github.com/ruby-oembed/ruby-oembed/issues/77#issuecomment-727024682
    # @deprecated *Note*: This method will be be removed in the future.
    def FacebookPost.new(access_token:)
      self.access_token = access_token
      self
    end
  end
end
