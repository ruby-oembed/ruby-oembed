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
